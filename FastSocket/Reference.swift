//
//  Reference.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
/// OperationalCodes are used to evaluate handshake,
/// to determine the end of a message and to
/// check if the connection was closed
internal enum OperationalCode: UInt8 {
    /// finish byte is used on every end of a message
    case finish = 0x3
    /// accept byte is used by the handshake
    case accept = 0x6
    /// 0x07 reserved
    /// connectionClose byte to determine if the backend has
    /// closed the connection
    case connectionClose = 0x8
    /// 0x9 - 0xF
}
/// ControlCodes are used to determine different
/// message types
internal enum ControlCode: UInt8 {
    /// continue is currently a placeholder byte
    case `continue` = 0x0
    /// text byte for string based messages
    case string = 0x1
    /// binary byte for data bases messages
    case binary = 0x2
}
