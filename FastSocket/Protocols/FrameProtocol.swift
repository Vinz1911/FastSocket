//
//  FrameProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 29.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
/// The framing protocol
internal protocol FrameProtocol {
    var on: FrameClosures { get set }
    // create instance of Frame
    init()
    /// create a FastSocket Protocol compliant message frame
    /// - parameters:
    ///     - data: the data that should be send
    ///     - opcode: the frames Opcode, e.g. .binary or .text
    func create(data: Data, opcode: Opcode) -> Data
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    func parse(data: Data) throws
}
