//
//  Data+Extensions.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
internal extension Data {
    /// slice data into chunks:
    /// - parameters:
    ///     - size: size of the sliced chunks
    func chunked(by size: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, self.count)])
        }
    }
}

extension Data: SendProtocol {
    // conformance to send protocol
}
