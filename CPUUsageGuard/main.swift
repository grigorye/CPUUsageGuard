//
//  main.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 07/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

private let defaults = UserDefaults.standard

guard let pattern = defaults.string(forKey: "pattern") else {
    fatalError("Missing -pattern")
}
guard let cpuUsageThreshold = Float(defaults.string(forKey: "cpuUsageThreshold") ?? "10") else {
    fatalError("Bad -cpuUsageThreshold")
}
guard let samplesThreshold = Int(defaults.string(forKey: "samplesThreshold") ?? "5") else {
    fatalError("Bad -samplesThreshold")
}
guard let interval = TimeInterval(defaults.string(forKey: "interval") ?? "60") else {
    fatalError("Bad -interval")
}
guard let topDelay = Int(defaults.string(forKey: "topDelay") ?? "5") else {
    fatalError("Bad -topDelay")
}

let config = Config(pattern: pattern, cpuUsageThreshold: cpuUsageThreshold, samplesThreshold: samplesThreshold, interval: interval, topDelay: topDelay)

dump(config, name: "config")

run(config: config) { (pid) in
    willKill(pid: pid)
    kill(pid, SIGTERM)
}

dispatchMain()
