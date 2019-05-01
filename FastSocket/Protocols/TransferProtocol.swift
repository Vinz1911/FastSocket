//
//  TransferProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Network
/// TransferProtocol is the conformance for the FastSocket Protocol `Engine`
/// this will be used to implement a fallback with foundation in the future
internal protocol TransferProtocol {
    /// the events
    var on: TransferClosures { get set }
    /// create a instance of NetworkTransfer
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    ///     - parameters: Network.framework Parameters `optional`
    ///     - queue: Dispatch Qeue `optional`
    init(host: String, port: UInt16, parameters: NWParameters, queue: DispatchQueue)
    /// connect to a host
    /// prevent reconnecting after a connection
    /// was successfully established
    func connect()
    /// disconnect from host and
    /// cleanup the connection
    func disconnect()
    /// write data async on tcp socket
    /// slices big data into chunks and send it stacked
    /// - parameters:
    ///     - data: the data which should be written on the socket
    func send(data: Data)
}
