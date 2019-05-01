//
//  Timer+Extension.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 24.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
internal extension Timer {
    /// Creates and returns a DispatchSourceTimer
    /// - parameters:
    ///     - interval: TimerInterval in Seconds
    ///     - withRepeat: true if you want to repeat, false for only call it once
    ///     - block: closure
    static func interval(interval: TimeInterval, withRepeat: Bool, block: @escaping () -> Void) -> DispatchSourceTimer {
        let dispatchTimer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue(label: "Timer.\(UUID().uuidString)"))
        dispatchTimer.setEventHandler(handler: block)
        if withRepeat {
            dispatchTimer.schedule(deadline: .now(), repeating: interval)
        } else {
            dispatchTimer.schedule(deadline: .now() + interval, repeating: .never)
        }
        dispatchTimer.resume()
        return dispatchTimer
    }
}
