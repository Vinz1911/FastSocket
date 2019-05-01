//
//  FastSocketProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 16.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Network

public protocol FastSocketProtocol {
    /// public access to the Network.framework parameter options
    /// that gives you the ability (for example) to define on which
    /// interface the traffic should be send
    var parameters: NWParameters { get set }
    /// create a instance of FastSocket
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    init(host: String, port: UInt16)
    /// connect to the server
    /// try to establish a connection to a
    /// FastSocket compliant server
    func connect()
    /// disconnect from the server
    /// closes the connection `normally`
    func disconnect()
    /// send a data message
    /// - parameters:
    ///     - data: the data that should be send
    func send(data: Data)
    /// send a string message
    /// - parameters:
    ///     - string: the string that should be send
    func send(string: String)
}
