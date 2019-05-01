//
//  FastSocketProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 16.04.19.
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
public protocol FastSocketProtocol {
    /// public access to the event based closures
    var on: FastSocketClosures { get set }
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
