//
//  Frame.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
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

/// Frame is a helper class for the FastSocket Protocol
/// it is used to create new message frames or to parse
/// received Data back to it's raw type
internal final class Frame: FrameProtocol {
    internal var on = FrameClosures()
    private var readBuffer = Data()

    internal required init() {
    }
    /// create a FastSocket Protocol compliant message frame
    /// - parameters:
    ///     - data: the data that should be send
    ///     - opcode: the frames Opcode, e.g. .string or .data
    ///     - isFinal: send a close frame to the host default is false
    internal func create(data: Data, opcode: Opcode, isFinal: Bool = false) throws -> Data {
        var outputFrame = Data()
        let payloadLengthBytes = UInt64(data.count + Constant.overheadSize).data()
        if isFinal {
            outputFrame.append(Opcode.finish.rawValue)
        } else {
            outputFrame.append(Opcode.continue.rawValue)
        }
        outputFrame.append(opcode.rawValue)
        outputFrame.append(payloadLengthBytes)
        outputFrame.append(data)
        guard outputFrame.count <= Constant.maximumContentLength else {
            throw FastSocketError.writeBufferOverflow
        }
        return outputFrame
    }
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    internal func parse(data: Data) throws {
        guard !data.isEmpty else {
            throw FastSocketError.zeroData
        }
        self.readBuffer.append(data)
        guard self.readBuffer.count <= Constant.maximumContentLength else {
            throw FastSocketError.readBufferOverflow
        }
        guard self.readBuffer.count >= Constant.overheadSize else {
            return
        }
        guard self.readBuffer.count >= self.contentSize() else {
            return
        }
        while self.readBuffer.count >= self.contentSize() && self.contentSize() != 0 {
            let slice = Data(self.readBuffer[0...self.contentSize() - 1])
            switch slice[1] {
            case Opcode.string.rawValue:
                guard let string = String(bytes: try self.trimFrame(frame: slice), encoding: .utf8) else {
                    throw FastSocketError.parsingFailure
                }
                self.on.stringFrame(string)

            case Opcode.data.rawValue:
                self.on.dataFrame(try self.trimFrame(frame: slice))

            default:
                throw FastSocketError.unknownOpcode
            }
            if self.readBuffer.count > self.contentSize() {
                self.readBuffer = Data(self.readBuffer[self.contentSize()...])
            } else {
                self.readBuffer = Data()
            }
        }
    }
}

private extension Frame {
    /// private function to get parse the overhead size of a frame
    /// - parameters:
    ///     - data: data to extract content size from
    private func contentSize() -> UInt64 {
        guard self.readBuffer.count >= Constant.overheadSize else {
            return 0
        }
        let size = Data(self.readBuffer[2...9])
        return size.int()
    }
    /// private func to trimm frame to it's raw content
    /// - parameters:
    ///     - frame: the data to trimm
    private func trimFrame(frame: Data) throws -> Data {
        guard frame.count >= Constant.overheadSize else {
            throw FastSocketError.parsingFailure
        }
        let data = Data(frame[10...])
        return data
    }
}
