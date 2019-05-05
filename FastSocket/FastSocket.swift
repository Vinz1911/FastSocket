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
/// only 3 Bytes overhead per message, the handshake is done directly on TCP level.
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
    private var mutexLock = false
    /// create a instance of FastSocket
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    ///     - parameters: Network.framework Parameters `optional`
    public required init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
    /// connect to the server
    /// try to establish a connection to a
    /// FastSocket compliant server
    public func connect() {
        self.mutexLock = false
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
        guard self.mutexLock else {
            return
        }
        guard let transfer = self.transfer else {
            return
        }
        switch type(of: message) {
        case is String.Type:
            do {
                let frame = try self.frame.create(data: (message as! String).data(using: .utf8)!, opcode: .string)
                transfer.send(data: frame)
            } catch {
                self.onError(error)
            }

        case is Data.Type:
            do {
                let frame = try self.frame.create(data: message as! Data, opcode: .binary)
                transfer.send(data: frame)
            } catch {
                self.onError(error)
            }

        default:
            break
        }
    }
}

private extension FastSocket {
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
        let data = Constant.socketID.data(using: .utf8)
        self.transfer?.send(data: data!)
    }
    /// closures from the transfer protocol
    /// handles incoming data and handshake
    private func transferClosures() {
        self.transfer?.on.ready = {
            self.handShake()
        }
        self.transfer?.on.data = { data in
            if self.mutexLock {
                do {
                    try self.frame.parse(data: data)
                } catch {
                    self.onError(error)
                }
            }
            if !self.mutexLock {
                guard data.first == Opcode.accept.rawValue else {
                    self.onError(FastSocketError.handShakeFailed)
                    self.onError(FastSocketError.socketUnexpectedClosed)
                    return
                }
                self.mutexLock = true
                self.stopTimeout()
                self.on.ready()
            }
        }
        self.transfer?.on.close = self.on.close
        self.transfer?.on.error = self.onError
        self.transfer?.on.dataRead = self.on.dataRead
        self.transfer?.on.dataWritten = self.on.dataWritten
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
