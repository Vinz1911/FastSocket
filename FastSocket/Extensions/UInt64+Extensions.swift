//
//  Int+Extensions.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 09.05.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation
internal extension UInt64 {
    /// convert an integer value with BigEndianUint64
    /// to an Data array
    func data() -> Data {
        return withUnsafeBytes(of: UInt64(bigEndian: self)) { bytes in
            Data(bytes)
        }
    }
}
