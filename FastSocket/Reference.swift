//
//  Reference.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
/// ControlCode is used by the FastSocket Protocol
/// to determine when a message begins and when
/// a message is finished
internal enum ControlCode: UInt8 {
    /// continue is currently a placeholder byte
    case `continue` = 0x0
    /// accept byte is used by the handshake
    case accept = 0x06
    /// finish byte is used on every end of a message
    case finish = 0x03
}
/// Opcodes are used to evaluate the message type
internal enum Opcode: UInt8 {
    /// text byte for string based messages
    case string = 0x1
    /// binary byte for data bases messages
    case binary = 0x2
    // 3-7 reserved.
    /// connectionClose byte to determine if the backend has
    /// closed the connection
    case connectionClose = 0x8
}
