//
//  Config.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 08/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

struct Config {
    let pattern: String
    let cpuUsageThreshold: Float
    let samplesThreshold: Int
    let interval: TimeInterval
    let topDelay: Int
}
