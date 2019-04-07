//
//  Run.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 07/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

func run(config: Config) {
    let processFilter = ProcessFilter(pattern: config.pattern, topDelay: config.topDelay)
    let driver = Driver(cpuUsageThreshold: config.cpuUsageThreshold, samplesThreshold: config.samplesThreshold) { (pid) in
        dump(pid, name: "pid")
        kill(pid, 3)
    }
    
    repeating(interval: config.interval) {
        dump(Date(), name: "date", maxDepth: 0)
        statsFor(processFilter) { statsResult in
            guard let stats = try? statsResult.get() else {
                fatalError()
            }
            driver.process(stats)
        }
    }
}
