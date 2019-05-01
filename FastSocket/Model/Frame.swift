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
/// Frame is a helper class for the FastSocket Protocol
/// it is used to create new message frames or to parse
/// received Data back to it's raw type
internal class Frame: FrameProtocol {
    internal var on = FrameClosures()
    private var outputFrame = Data()
    private var inputFrame = Data()
    private var readBuffer = Data()

    internal required init() {
    }
    /// create a FastSocket Protocol compliant message frame
    /// - parameters:
    ///     - data: the data that should be send
    ///     - opcode: the frames Opcode, e.g. .binary or .text
    internal func create(data: Data, opcode: Opcode) -> Data {
        self.outputFrame = Data()
        self.outputFrame.append(opcode.rawValue)
        self.outputFrame.append(data)
        self.outputFrame.append(Opcode.finish.rawValue)
        return self.outputFrame
    }
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    internal func parse(data: Data) throws {
        guard !data.isEmpty else {
            throw FastSocketError.zeroData
        }
        self.readBuffer.append(data)
        guard data.last == Opcode.finish.rawValue else {
            // Do nothing, keep reading, keep walking
            return
        }
        guard let opcode = self.readBuffer.first else {
            throw FastSocketError.readBufferIssue
        }
        switch opcode {
        case Opcode.string.rawValue:
            self.on.stringFrame(self.trimmedFrame())

        case Opcode.binary.rawValue:
            self.on.dataFrame(self.trimmedFrame())

        default:
            throw FastSocketError.unknownOpcode
        }
        initializeFrame()
    }
}

private extension Frame {
    /// helper function to parse the frame
    private func trimmedFrame() -> Data {
        self.inputFrame = self.readBuffer.dropFirst()
        self.inputFrame = self.inputFrame.dropLast()
        return self.inputFrame
    }
    /// helper function to create readable frame
    private func initializeFrame() {
        self.readBuffer = Data()
        self.inputFrame = Data()
    }
}
