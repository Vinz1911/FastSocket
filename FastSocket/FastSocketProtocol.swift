//
//  FastSocketProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 16.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation
import Network

public protocol FastSocketProtocol {
    /// create a instance of FastSocket
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    ///     - options: Network.framework TCP options `optional`
    init(host: NWEndpoint.Host, port: NWEndpoint.Port, options: NWProtocolTCP.Options, queue: DispatchQueue)
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
