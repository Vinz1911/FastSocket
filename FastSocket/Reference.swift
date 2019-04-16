//
//  Reference.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation
/// ControlCode is used by the FastSocket Protocol
/// to determine when a message begins and when
/// a message is finished
enum ControlCode: UInt8 {
    /// continue is currently a placeholder byte
    case `continue` = 0x0
    /// accept byte is used by the handshake
    case accept =     0xFE
    /// finish byte is used on every end of a message
    case finish =     0xFF
}
/// Opcodes are used to evaluate the message type
enum Opcode: UInt8 {
    /// text byte for string based messages
    case text =            0x1
    /// binary byte for data bases messages
    case binary =          0x2
    // 3-7 reserved.
    /// connectionClose byte to determine if the backend has
    /// closed the connection
    case connectionClose = 0x8
}
