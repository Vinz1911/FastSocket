//
//  NetworkTransfer.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Network
/// NetworkTransfer is a raw TCP transfer
/// it uses the Network.framework. This is
/// the `Engine` of the FastSocket Protocol.
/// It allows to enter directly the TCP Options
internal class NetworkTransfer: TransferProtocol {
    internal var on = TransferClosures()
    private var connection: NWConnection
    private var monitor = NWPathMonitor()
    private var queue: DispatchQueue
    private var isRunning: Bool = false
    private var isConnected: Bool = false
    private var mutexLock: Bool = false
    private var connectionState: NWConnection.State = .cancelled
    /// create a instance of NetworkTransfer
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    ///     - parameters: Network.framework Parameters `optional`
    ///     - queue: Dispatch Qeue `optional`
    required init(host: String, port: UInt16, parameters: NWParameters = NWParameters(tls: nil), queue: DispatchQueue = DispatchQueue(label: "NetworkTransfer.Queue.\(UUID().uuidString)", qos: .userInitiated, attributes: .concurrent)) {
        self.connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: parameters)
        self.queue = queue
    }
    /// connect to a host
    /// prevent reconnecting after a connection
    /// was successfully established
    internal func connect() {
        guard !self.isConnected else {
            return
        }
        self.connectionStateHandler()
        self.networkPathMonitor()
        self.connection.start(queue: self.queue)
        self.isRunning = true
        self.readLoop()
    }
    /// disconnect from host and
    /// cleanup the connection
    internal func disconnect() {
        self.clean()
    }
    /// write data async on tcp socket
    /// slices big data into chunks and send it stacked
    /// - parameters:
    ///     - data: the data which should be written on the socket
    internal func send(data: Data) {
        self.connection.batch { [weak self] in
            guard let self = self else {
                return
            }
            guard !self.mutexLock else {
                self.on.error(FastSocketError.writeBeforeClear)
                return
            }
            self.mutexLock = true
            guard self.connectionState == .ready else {
                return
            }
            let queued = data.chunked(by: Constant.maximumLength)
            guard !queued.isEmpty else {
                return
            }
            for (i, data) in queued.enumerated() {
                self.connection.send(content: Data(data), completion: .contentProcessed({ error in
                    guard error == nil else {
                        self.on.error(error)
                        return
                    }
                    self.on.dataOutput(data.count)
                    if i == queued.endIndex - 1 {
                        self.mutexLock = false
                    }
                }))
            }
        }
    }
}

private extension NetworkTransfer {
    /// check connection state
    private func connectionStateHandler() {
        self.connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else {
                return
            }
            self.connectionState = state
            if case .ready = state {
                self.on.ready()
                self.doConnect()
            }
            if case .waiting(let error) = state {
                self.on.error(error)
            }
            if case .failed(let error) = state {
                self.on.error(error)
            }
            if case .cancelled = state {
                self.on.close()
            }
        }
    }
    /// helper on connecting
    private func doConnect() {
        guard !isConnected else {
            return
        }
        self.isConnected = true
        self.isRunning = true
    }
    /// cleanup a connection
    /// on disconnect
    private func clean() {
        self.isRunning = false
        self.isConnected = false
        self.connection.cancel()
    }
    /// a network path monitor
    /// used to detect if network is unrechable
    private func networkPathMonitor() {
        self.monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {
                return
            }
            guard path.status == .unsatisfied else {
                return
            }
            self.clean()
            self.on.error(FastSocketError.networkUnreachable)
        }
        self.monitor.start(queue: DispatchQueue(label: "NWPath.Queue.\(UUID().uuidString)", qos: .userInitiated))
    }
    /// readloop for the tcp socket incoming data
    private func readLoop() {
        guard self.isRunning else {
            return
        }
        self.connection.receive(minimumIncompleteLength: Constant.minimumIncompleteLength, maximumLength: Constant.maximumLength) { [weak self] data, context, isComplete, error in
            guard let self = self else {
                return
            }
            if let error = error {
                guard error != NWError.posix(POSIXErrorCode(rawValue: 89)!) else {
                    return
                }
                self.on.error(error)
                return
            }
            if let data = data {
                self.on.data(data)
                self.on.dataInput(data.count)
            }
            if isComplete && data == nil, context == nil, error == nil {
                self.clean()
                self.on.close()
                return
            }
            self.readLoop()
        }
    }
}
