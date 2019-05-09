//
//  Array+Extensions.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 09.05.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation
internal extension Array where Element == UInt8 {
    func toInt() -> Int {
        return self.withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: Int.self, capacity: 1) {
                $0.pointee
            }
        }
    }
}
