//
//  Closures.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
/// FrameClosures are used by the framing
internal struct FrameClosures {
    /// provides if a dataframe was successfully passed
    internal var dataFrame: CallbackData = { _ in }
    /// provides if a stringframe was successfully passed
    internal var stringFrame: CallbackData = { _ in }
}
/// TransferClosures are used by the network transfer
internal struct TransferClosures {
    /// called if the connection is ready
    internal var ready: Callback = { }
    /// called if the connection was closed
    internal var close: Callback = { }
    /// called if data is provided
    internal var data: CallbackData = { data in }
    /// called if an error is provided
    internal var error: CallbackError = { error in }
    /// called if bytes are readed from the socket
    internal var dataRead: CallbackInt = { bytes in }
    /// called if bytes are written on the socket
    internal var dataWritten: CallbackInt = { bytes in }
}
/// FastSocketClosures are used by the Protocol to provide
/// necessary features
public struct FastSocketClosures {
    /// called if the connection is ready
    public var ready: Callback = { }
    /// called if the connection was closed
    public var close: Callback = { }
    /// called if a string is provided
    public var string: CallbackString = { string in }
    /// called if data is provided
    public var data: CallbackData = { data in }
    /// called if an error is provided
    public var error: CallbackError = { error in }
    /// called if bytes are readed from the socket
    public var dataRead: CallbackInt = { bytes in }
    /// called if bytes are written on the socket
    public var dataWritten: CallbackInt = { bytes in }
}
