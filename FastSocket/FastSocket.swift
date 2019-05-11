//
//  FastSocket.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
// swiftlint:disable force_cast
import Foundation
import Network
/// FastSocket is a proprietary communication protocol directly
/// written on top of TCP. It's a message based protocol which allows you
/// to send text and binary based messages. The protocol is so small it have
/// only 10 Bytes overhead per message, the handshake is done directly on TCP level.
/// The motivation behind this protocol was, to use it as `Speedtest Protocol`, a
/// low level TCP communication protocol to measure TCP throughput performance. -> FastSocket is the answer
/// FastSocket allows to enter all possible TCP Options if needed and is completely non-blocking and async, thanks to GCD
public final class FastSocket: FastSocketProtocol {
    public var on = FastSocketClosures()
    public var parameters = NWParameters(tls: nil)
    private var host: String
    private var port: UInt16
    private var frame = Frame()
    private var transfer: TransferProtocol?
    private var timer: DispatchSourceTimer?
    private var isLocked = false
    /// create a instance of FastSocket
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    public required init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
    /// connect to the server
    /// try to establish a connection to a
    /// FastSocket compliant server
    public func connect() {
        self.isLocked = false
        self.transfer = NetworkTransfer(host: self.host, port: self.port, parameters: self.parameters)
        self.transferClosures()
        self.frameClosures()
        guard let transfer = self.transfer else {
            return
        }
        transfer.connect()
        self.startTimeout()
    }
    /// disconnect from the server
    /// closes the connection `normally`
    public func disconnect() {
        guard let transfer = self.transfer else {
            return
        }
        transfer.disconnect()
        self.stopTimeout()
    }
    /// generic send function, send data or string based messages
    /// - parameters:
    ///     - message: generic type (accepts data or string)
    public func send<T: SendProtocol>(message: T) {
        do {
            try self.write(message: message)
        } catch {
            self.onError(error)
        }
    }
}

private extension FastSocket {
    /// generic write function, send data or string based messages
    /// internal use to handle the throw in the send function
    /// - parameters:
    ///     - message: generic type (accepts data or string)
    private func write<T: SendProtocol>(message: T) throws {
        guard self.isLocked else {
            return
        }
        guard let transfer = self.transfer else {
            return
        }
        switch message {
        case is String:
            let frame = try self.frame.create(data: (message as! String).data(using: .utf8)!, opcode: .string)
            transfer.send(data: frame)

        case is Data:
            let frame = try self.frame.create(data: message as! Data, opcode: .data)
            transfer.send(data: frame)

        default:
            break
        }
    }
    /// suspends timeout and report on error
    /// - parameters:
    ///     - error: the error `optional`
    private func onError(_ error: Error?) {
        if let timer = self.timer {
            timer.cancel()
        }
        guard let error = error else {
            return
        }
        self.on.error(error)
        self.disconnect()
    }
    /// send the handshake frame
    private func handShake() {
        guard let transfer = self.transfer else {
            return
        }
        let data = Constant.socketID.data(using: .utf8)
        transfer.send(data: data!)
    }
    /// closures from the transfer protocol
    /// handles incoming data and handshake
    private func transferClosures() {
        guard var transfer = self.transfer else {
            return
        }
        transfer.on.ready = { [weak self] in
            guard let self = self else {
                return
            }
            self.handShake()
        }
        transfer.on.data = { [weak self] data in
            guard let self = self else {
                return
            }
            switch self.isLocked {
            case true:
                do {
                    try self.frame.parse(data: data)
                } catch {
                    self.onError(error)
                }

            case false:
                guard data.first == Opcode.accept.rawValue else {
                    self.onError(FastSocketError.handShakeFailed)
                    return
                }
                self.isLocked = true
                self.stopTimeout()
                self.on.ready()
            }
        }
        transfer.on.close = self.on.close
        transfer.on.error = self.onError
        transfer.on.dataRead = self.on.dataRead
        transfer.on.dataWritten = self.on.dataWritten
    }
    /// closures from Frame
    /// returns the parsed messages
    private func frameClosures() {
        self.frame.on.stringFrame = self.on.string
        self.frame.on.dataFrame = self.on.data
    }
    /// start timeout on connecting
    private func startTimeout() {
        self.timer = Timer.interval(interval: Constant.timeout, withRepeat: false) {
            self.onError(FastSocketError.timeoutError)
        }
    }
    /// stop timeout
    private func stopTimeout() {
        guard let timer = self.timer else {
            return
        }
        timer.cancel()
    }
}
