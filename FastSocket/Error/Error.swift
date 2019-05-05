//
//  Error.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// Error handling for the FastSocket Protocol
public enum FastSocketError: Int, Error {
    /// none is a placeholder
    case none = 0
    /// thrown if handshake is failed
    case handShakeFailed = 100
    /// thrown on connection timeout
    case timeoutError = 101
    /// thrown if the could not connect to a network or loses connection
    case networkUnreachable = 102
    /// thrown if sending failed
    case sendFailed = 200
    /// thrown if sending before connection is ready
    case sendToEarly = 201
    /// thrown if socket was closed (maybe for internal use)
    case socketClosed = 202
    /// thrown if socket was closed not normally
    case socketUnexpectedClosed = 203
    /// thrown if try to write data before previous data was written
    case writeBeforeClear = 204
    /// thrown if message parsing failed
    case parsingFailure = 300
    /// thrown if message parser get's zer0 data
    case zeroData = 301
    /// thrown if something werid happen to the readbuffer
    case readBufferIssue = 302
    /// thrown if a readbuffer overflow is encountered
    case readBufferOverflow = 303
    /// thrown if a writebuffer overflow is encountered
    case writeBufferOverflow = 304
    /// thrown if opcode was unknown
    case unknownOpcode = 1000
}

public extension FastSocketError {
    static var errorDomain: String { return "fastsocket.error" }
    var errorCode: Int { return self.rawValue }
    var errorUserInfo: [String: String] {
        switch self {
        case .none:
            return [NSLocalizedDescriptionKey: "null"]

        case .handShakeFailed:
            return [NSLocalizedDescriptionKey: "handshake failure, not protocol compliant"]

        case .timeoutError:
            return [NSLocalizedDescriptionKey: "connection timeout error"]

        case .networkUnreachable:
            return [NSLocalizedDescriptionKey: "network is down or not reachable"]

        case .sendFailed:
            return [NSLocalizedDescriptionKey: "send failure, data was not written"]

        case .sendToEarly:
            return [NSLocalizedDescriptionKey: "socket is not ready, could not send"]

        case .socketClosed:
            return [NSLocalizedDescriptionKey: "socket was closed"]

        case .socketUnexpectedClosed:
            return [NSLocalizedDescriptionKey: "socket was unexpected closed"]

        case .writeBeforeClear:
            return [NSLocalizedDescriptionKey: "previous data not finally written!, cannot write on socket"]

        case .parsingFailure:
            return [NSLocalizedDescriptionKey: "message parsing error, no valid UTF-8"]

        case .zeroData:
            return [NSLocalizedDescriptionKey: "data is empty cannot parse into message"]

        case .readBufferIssue:
            return [NSLocalizedDescriptionKey: "readbuffer issue, is empty or wrong data"]

        case .readBufferOverflow:
            return [NSLocalizedDescriptionKey: "readbuffer overflow!"]

        case .writeBufferOverflow:
            return [NSLocalizedDescriptionKey: "writebuffer overflow!"]

        case .unknownOpcode:
            return [NSLocalizedDescriptionKey: "unknown opcode, cannot parse message"]
        }
    }
}
