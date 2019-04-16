//
//  Error.swift
//  CustomTCP
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
    case handShakeFailed = 1
    /// thrown on connection timeout
    case timeoutError = 2
    /// thrown if sending failed
    case sendFailed = 3
    /// thrown if sending before connection is ready
    case sendToEarly = 4
    /// thrown if socket was closed (maybe for internal use)
    case socketClosed = 5
    /// thrown if socket was closed not normally
    case socketUnexpectedClosed = 6
    /// thrown if message parsing failed
    case parsingFailure = 7
    /// thrown if message parser get's zer0 data
    case zeroData = 8
    /// thrown if message type was unknown
    case invalidMessageType = 9
    /// thrown if opcode was unknown
    case unknownOpcode = 10
}

extension FastSocketError: CustomNSError {
    public static var errorDomain: String { return "fastSocket.error" }
    public var errorCode: Int { return self.rawValue }
    public var errorUserInfo: [String: Any] {
        switch self {
        case .none:
            return [NSLocalizedDescriptionKey: "null"]
        case .handShakeFailed:
            return [NSLocalizedDescriptionKey: "handshake failure, not FastSocket compliant"]
        case .timeoutError:
            return [NSLocalizedDescriptionKey: "connection timeout error"]
        case .sendFailed:
            return [NSLocalizedDescriptionKey: "send failure, data was not written"]
        case .sendToEarly:
            return [NSLocalizedDescriptionKey: "socket is not ready, could not send"]
        case .socketClosed:
            return [NSLocalizedDescriptionKey: "socket was closed"]
        case .socketUnexpectedClosed:
            return [NSLocalizedDescriptionKey: "socket was unexpected closed"]
        case .parsingFailure:
            return [NSLocalizedDescriptionKey: "message parsing error, no valid UTF-8"]
        case .zeroData:
            return [NSLocalizedDescriptionKey: "Data is empty cannot parse into Message"]
        case .invalidMessageType:
            return [NSLocalizedDescriptionKey: "Unknown Opcode for Message Type, cannot parse Message"]
        case .unknownOpcode:
            return [NSLocalizedDescriptionKey: "Unknown Opcode, cannot parse Message"]
        }
    }
}
