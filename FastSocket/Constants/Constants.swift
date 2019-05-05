//
//  Constants.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// Constants used by the protocol
internal enum Constant {
    /// for tcp socket reading, minimum stream length
    static let minimumIncompleteLength: Int = 1
    /// maximum tcp frame size
    static let maximumLength: Int = 8192
    /// the FastSocket ID used by the handshake
    static let socketID: String = "6D8EDFD9-541C-4391-9171-AD519876B32E"
    /// timeout time
    static let timeout: TimeInterval = 5.0
    /// maximum content size
    static let maximumContentLength: Int = 16_777_216
}
