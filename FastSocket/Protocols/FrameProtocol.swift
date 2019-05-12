//
//  FrameProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 29.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation

// 0                   1       N
// +-------------------+-------+
// |0|1|2 3 4 5 6 7 8 9|0 1 2 3|
// +-+-+---------------+-------+
// |F|O| FRAME LENGTH  |PAYLOAD|
// |I|P|     (8)       |  (N)  |
// |N|C|               |       |
// +-+-+---------------+-------+
// : Payload Data continued ...:
// + - - - - - - - - - - - - - +
// | Payload Data continued ...|
// +---------------------------+
//
// This describes the framing protocol.
// - FIN: 0x3
//      - The first byte is used to inform the the other side, that the
//      - connection is finished and can be closed, this is used to prevent
//      - that a connection will be closed but there are unread bytes on the connection
// - OPC:
//      - 0x0: this is the continue byte (currently a placeholder)
//      - 0x1: this is the string byte which is used for string based messages
//      - 0x2: this is the data byte which is used for data based messages
//      - 0x3: this is the fin byte, which is part of OPC but is on the first place in the protocol
//      - 0x6: this is the accept byte and is used by the handshake
//      - 0x7 - 0xF: this bytes are reserved
// - FRAME LENGTH:
//      - this uses 8 bytes to store the entire frame size as a big endian uint64 value
// - PAYLOAD:
//      - continued payload data

/// The framing protocol
internal protocol FrameProtocol {
    var on: FrameClosures { get set }
    // create instance of Frame
    init()
    /// create a FastSocket Protocol compliant message frame
    /// - parameters:
    ///     - data: the data that should be send
    ///     - opcode: the frames Opcode, e.g. .data or .string
    ///     - isFinal: send a close frame to the host default is false
    func create(data: Data, opcode: Opcode, isFinal: Bool) throws -> Data
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    func parse(data: Data) throws
}
