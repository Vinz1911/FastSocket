//
//  Opcodes.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// Opcodes are used to evaluate and control the framing,
/// the handshake and the transfer process
internal enum Opcode: UInt8 {
    /// continue is currently a placeholder byte
    case `continue` = 0x0
    /// text byte for string based messages
    case string = 0x1
    /// binary byte for data bases messages
    case data = 0x2
    /// finish byte is used on every end of a message
    case finish = 0x3
    /// accept byte is used by the handshake
    case accept = 0x6
    /// 0x07 - 0xF reserved
}
