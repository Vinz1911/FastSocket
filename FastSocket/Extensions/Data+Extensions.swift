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
    func chunked(by size: Int) -> [Data] {
        return stride(from: 0, to: self.count, by: size).map {
            Data(Array(self[$0..<Swift.min($0 + size, self.count)]))
        }
    }
}
