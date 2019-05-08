//
//  Frame.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
// 0                 1                              N                 N
// +-----------------+------------------------------+-----------------+
// |0 1 2 3 4 5 6 7 8|        ... Continue          |0 1 2 3 4 5 6 7 8|
// +-----------------+------------------------------+-----------------+
// |   O P C O D E   |         Payload Data...      |  F I N B Y T E  |
// +-----------------+------------------------------+-----------------+
//
import Foundation
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
    ///     - opcode: the frames Opcode, e.g. .binary or .text
    internal func create(data: Data, opcode: Opcode) throws -> Data {
        var outputFrame = Data()
        outputFrame.append(opcode.rawValue)
        outputFrame.append(data)
        outputFrame.append(Opcode.finish.rawValue)
        guard outputFrame.count <= Constant.maximumContentLength else {
            throw FastSocketError.writeBufferOverflow
        }
        return outputFrame
    }
    /// TODO: HIGH PERFORMANCE IMPACT LOLOLOLOL
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    internal func parse(data: Data) throws {
        guard !data.isEmpty else {
            throw FastSocketError.zeroData
        }
        self.readBuffer.append(data)
        if self.readBuffer.count > Constant.maximumContentLength {
            throw (FastSocketError.readBufferOverflow)
        }
        guard self.readBuffer.contains(Opcode.finish.rawValue) else {
            return
        }
        let splitted = self.readBuffer.split(separator: Opcode.finish.rawValue, maxSplits: 1, omittingEmptySubsequences: false)
        guard let frame = splitted.first else {
            throw FastSocketError.parsingFailure
        }
        guard let opcode = frame.first else {
            throw FastSocketError.readBufferIssue
        }
        switch opcode {
        case Opcode.string.rawValue:
            guard let string = String(bytes: frame.dropFirst(), encoding: .utf8) else {
                throw FastSocketError.parsingFailure
            }
            self.on.stringFrame(string)

        case Opcode.binary.rawValue:
            self.on.dataFrame(frame.dropFirst())

        default:
            throw FastSocketError.unknownOpcode
        }
        if let last = splitted.last {
            self.readBuffer = last
        }
    }
}

private extension Frame {
    /// helper function to parse the frame
    private func trimmedFrame() -> Data {
        let inputFrame = self.readBuffer[1...self.readBuffer.count - 2]
        return inputFrame
    }
    /// helper function to create readable frame
    private func initializeBuffer() {
        self.readBuffer = Data()
    }
}
