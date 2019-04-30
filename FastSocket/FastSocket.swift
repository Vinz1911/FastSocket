//
//  FastSocket.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Network
/// FastSocket is a proprietary communication protocol directly
/// written on top of TCP. It's a message based protocol which allows you
/// to send text and binary based messages. The protocol is so small it have
/// only 3 Bytes overhead per message, the handshake is done directly on TCP level.
/// The motivation behind this protocol was, to use it as `Speedtest Protocol`, a
/// low level TCP communication protocol to measure TCP throughput performance. -> FastSocket is the answer
/// FastSocket allows to enter all possible TCP Options if needed and is completely non-blocking and async, thanks to GCD
public class FastSocket: FastSocketProtocol {
    public var on = FastSocketClosures()
    public var parameters = NWParameters(tls: nil)
    private var host: String
    private var port: UInt16
    private var queue: DispatchQueue
    private var frame = Frame()
    private var transfer: TransferProtocol?
    private var timer: DispatchSourceTimer?
    private var locked = false
    /// create a instance of FastSocket
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    ///     - parameters: Network.framework Parameters `optional`
    ///     - queue: Dispatch Queue `optional`
    public required init(host: String, port: UInt16, queue: DispatchQueue = DispatchQueue(label: "FastSocket.Dispatch.\(UUID().uuidString)", qos: .userInitiated, attributes: .concurrent)) {
        self.host = host
        self.port = port
        self.queue = queue
    }
    /// connect to the server
    /// try to establish a connection to a
    /// FastSocket compliant server
    public func connect() {
        self.locked = false
        self.transfer = NetworkTransfer(host: self.host, port: self.port, parameters: self.parameters, queue: self.queue)
        self.transferClosures()
        self.frameClosures()
        self.transfer?.connect()
        self.startTimeout()
    }
    /// disconnect from the server
    /// closes the connection `normally`
    public func disconnect() {
        guard let transfer = self.transfer else {
            return
        }
        transfer.disconnect()
        self.clean(nil)
    }
    /// send a data message
    /// - parameters:
    ///     - data: the data that should be send
    public func send(data: Data) {
        guard self.locked else {
            self.clean(FastSocketError.sendToEarly)
            return
        }
        let frame = self.frame.create(data: data, opcode: .binary)
        guard let transfer = self.transfer else {
            return
        }
        transfer.send(data: frame)
    }
    /// send a string message
    /// - parameters:
    ///     - string: the string that should be send
    public func send(string: String) {
        guard self.locked else {
            self.clean(FastSocketError.sendToEarly)
            return
        }
        let frame = self.frame.create(data: string.data(using: .utf8)!, opcode: .string)
        guard let transfer = self.transfer else {
            return
        }
        transfer.send(data: frame)
    }
}

private extension FastSocket {
    /// suspends timeout and report on error
    private func clean(_ error: Error?) {
        if let timer = self.timer {
            timer.cancel()
        }
        guard let error = error else {
            return
        }
        self.on.error(error)
    }
    /// send the handshake frame
    private func handShake() {
        let keyData = Constant.socketID.data(using: .utf8)
        self.transfer?.send(data: keyData!)
    }
    /// closures from the transfer protocol
    /// handles incoming data and handshake
    private func transferClosures() {
        self.transfer?.on.ready = {
            self.handShake()
        }
        self.transfer?.on.data = { data in
            if self.locked {
                do {
                    try self.frame.parse(data: data)
                } catch {
                    self.clean(error)
                }
            }
            if !self.locked {
                guard data.first == ControlCode.accept.rawValue else {
                    self.disconnect()
                    self.clean(FastSocketError.handShakeFailed)
                    self.clean(FastSocketError.socketUnexpectedClosed)
                    return
                }
                self.locked = true
                self.clean(nil)
                self.on.ready()
            }
        }
        self.transfer?.on.close = self.on.close
        self.transfer?.on.error = self.clean
        self.transfer?.on.dataInput = self.on.dataRead
        self.transfer?.on.dataOutput = self.on.dataWritten
    }
    /// closures from Frame
    /// returns the parsed messages
    private func frameClosures() {
        self.frame.on.stringFrame = { data in
            guard let string = String(data: data, encoding: .utf8) else {
                self.clean(FastSocketError.parsingFailure)
                return
            }
            self.on.string(string)
        }

        self.frame.on.dataFrame = { data in
            self.on.data(data)
        }
    }
    /// start timeout on connecting
    private func startTimeout() {
        self.timer = Timer.interval(interval: Constant.timeout, withRepeat: false) {
            self.disconnect()
            self.clean(FastSocketError.timeoutError)
        }
    }
}
