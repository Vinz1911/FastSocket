//
//  Int+Extensions.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 09.05.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation
internal extension Int {
    /// convert an integer value with BigEndianUint64
    /// to an Data array
    func toData() -> Data {
        return withUnsafeBytes(of: UInt64(bigEndian: UInt64(self))) {
            Data($0)
        }
    }
}
