//
//  Repeating.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 08/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

func repeating(interval: TimeInterval, _ block: @escaping () -> Void) {
    let dispatchSourceTimer = DispatchSource.makeTimerSource()
    dispatchSourceTimer.schedule(deadline: .now(), repeating: .seconds(Int(interval)))
    dispatchSourceTimer.setEventHandler() {
        block()
        _ = dispatchSourceTimer
    }
    dispatchSourceTimer.resume()
}
