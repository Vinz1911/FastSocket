//
//  FastSockets.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
import Network
/// FastSockets is a proprietary communication protocol directly
/// written on top of TCP. It's a message based protocol which allows you
/// to send text and binary based messages. The protocol is so small it have
/// only 10 Bytes overhead per message, the handshake is done directly on TCP level.
/// The motivation behind this protocol was, to use it as `Speedtest Protocol`, a
/// low level TCP communication protocol to measure TCP throughput performance. -> FastSockets is the answer
/// FastSockets allows to enter all possible TCP Options if needed and is completely non-blocking and async, thanks to GCD
public final class FastSockets: FastSocketProtocol {
    public var on = FastSocketCallback()
    public var parameters = TransferParameters()
    private var host: String
    private var port: UInt16
    private var frame = Frame()
    private var transfer: TransferProtocol?
    private var timer: DispatchSourceTimer?
    private var digest = Data()
    private var type: TransferType
    private var isLocked = false
    /// create a instance of FastSockets
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    ///     - type: the transfer type (.tcp or .tls)
    public required init(host: String, port: UInt16, type: TransferType = .tcp) {
        self.host = host
        self.port = port
        self.type = type
    }
    /// connect to the server
    /// try to establish a connection to a
    /// FastSockets compliant server
    public func connect() {
        initialize()
        guard let transfer = transfer else { return }
        transfer.connect()
        startTimeout()
    }
    /// disconnect from the server
    /// closes the connection `normally`
    public func disconnect() {
        guard let transfer = transfer else { return }
        transfer.disconnect()
        stopTimeout()
    }
    /// generic send function, send data or string based messages
    /// - parameters:
    ///     - message: generic type (accepts data or string)
    public func send<T: MessageProtocol>(message: T) {
        guard isLocked, let transfer = transfer else { return }
        do {
            let data = try frame.create(message: message)
            transfer.send(data: data)
        } catch {
            onError(error)
        }
    }
}

private extension FastSockets {
    /// private func to reset all needed values
    /// and initialize
    private func initialize() {
        guard !host.isEmpty else {
            onError(FastSocketError.emptyHost)
            return
        }
        isLocked = false
        digest = Data()
        transfer = NetworkTransfer(host: host, port: port, type: type, parameters: parameters)
        transferCallbacks()
    }
    /// suspends timeout and report on error
    /// - parameters:
    ///     - error: the error `optional`
    private func onError(_ error: Error?) {
        if let timer = timer {
            timer.cancel()
        }
        guard let error = error else { return }
        on.error(error)
        disconnect()
    }
    /// send the handshake frame
    private func handshake() {
        guard let transfer = transfer else { return }
        guard let data = UUID().uuidString.data(using: .utf8) else {
            onError(FastSocketError.handshakeInitializationFailed)
            return
        }
        digest = data.sha256
        transfer.send(data: data)
    }
    /// start timeout on connecting
    private func startTimeout() {
        timer = Timer.interval(interval: Constant.timeout, withRepeat: false) {
            self.onError(FastSocketError.timeoutError)
        }
    }
    /// stop timeout
    private func stopTimeout() {
        guard let timer = timer else { return }
        timer.cancel()
    }
}

private extension FastSockets {
    /// closures from the transfer protocol
    /// handles incoming data and handshake
    private func transferCallbacks() {
        guard let transfer = transfer else { return }
        transfer.on.ready = { [weak self] in
            guard let self = self else { return }
            self.handleReadyState()
        }
        transfer.on.message = { [weak self] data in
            guard let self = self else { return }
            self.handleMessageState(data: data)
        }
        transfer.on.error = onError
        transfer.on.close = on.close
        transfer.on.bytes = on.bytes
    }
}

private extension FastSockets {
    /// this function is called from
    /// the transfer, to handle all necessary
    /// things `on ready`
    private func handleReadyState() {
        self.handshake()
    }
    /// this function is called from
    /// the transfer, to handle all necessary
    /// things `on message`
    private func handleMessageState(data: MessageProtocol) {
        guard case let data as Data = data else { return }
        switch self.isLocked {
        case true:
            do {
                try self.frame.parse(data: data) { message in
                    on.message(message)
                }
            } catch {
                self.onError(error)
            }
        case false:
            guard data == self.digest else {
                self.onError(FastSocketError.handshakeVerificationFailed)
                return
            }
            self.isLocked = true
            self.stopTimeout()
            self.on.ready()
        }
    }
}
