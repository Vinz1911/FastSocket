//
//  Data+Extensions.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
extension Data: SendProtocol {
    // conformance to send protocol
}
internal extension Data {
    /// slice data into chunks:
    /// - parameters:
    ///     - size: size of the sliced chunks
    func chunk(by size: Int) -> [Data] {
        return stride(from: 0, to: self.count, by: size).map { count in
            Data(self[count..<Swift.min(count + size, self.count)])
        }
    }
    /// convert big endian to uint64
    func int() -> UInt64 {
        guard !self.isEmpty else {
            return 0
        }
        return UInt64(bigEndian: withUnsafeBytes { bytes in
            bytes.load(as: UInt64.self)
        })
    }
}
