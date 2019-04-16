//
//  Frame.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation

// +---+------------------------------+-+
// |0 1|         ... Continue         |N|
// +---+------------------------------+-+
// | O |                              |F|
// | P |         Payload Data...      |I|
// | C |                              |N|
// | O |         Payload Data...      |B|
// | D |                              |Y|
// | E |         Payload Data...      |T|
// |   |                              |E|
// |   |         Payload Data...      | |
// |   |                              | |
// +---+------------------------------+-+

/// Frame is a helper class for the FastSocket Protocol
/// it is used to create new message frames or to parse
/// received Data back to it's raw type
internal class Frame {
    // TODO: Generify this
    internal var onBinaryFrame: CallbackData = { _ in }
    internal var onTextFrame: CallbackData = { _ in }
    internal var outputFrame: Data = Data()
    internal var inputFrame: Data = Data()
    internal var readBuffer: Data = Data()

    internal init() {
    }
    /// create a FastSocket Protocol compliant message frame
    /// - parameters:
    ///     - data: the data that should be send
    ///     - opcode: the frames opcode, e.g. .binary or .text
    internal func create(data: Data, opcode: Opcode) -> Data {
        self.outputFrame = Data()
        self.outputFrame.append(opcode.rawValue)
        self.outputFrame.append(ControlCode.continue.rawValue)
        self.outputFrame.append(data)
        self.outputFrame.append(ControlCode.finish.rawValue)
        return self.outputFrame
    }
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    internal func parse(data: Data) throws {
        guard data.count > 0 else {
            throw FastSocketError.zeroData
        }
        self.readBuffer.append(data)

        guard data.last == ControlCode.finish.rawValue else {
            // Do nothing, keep reading, keep walking
            return
        }
        guard let opcode = self.readBuffer.first else {
            throw FastSocketError.invalidMessageType
        }
        switch opcode {
        case Opcode.text.rawValue:
            self.onTextFrame(trimmedFrame())
        case Opcode.binary.rawValue:
            self.onBinaryFrame(trimmedFrame())
        default:
            throw FastSocketError.unknownOpcode
        }
        initializeFrame()
    }
    /// helper function to parse the frame
    private func trimmedFrame() -> Data {
        self.inputFrame = self.readBuffer.dropFirst()
        self.inputFrame = self.inputFrame.dropFirst()
        self.inputFrame = self.inputFrame.dropLast()
        return self.inputFrame
    }
    /// helper function to create readable frame
    private func initializeFrame() {
        self.readBuffer = Data()
        self.inputFrame = Data()
    }
}
