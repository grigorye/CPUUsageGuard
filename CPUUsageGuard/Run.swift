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
        pgrep(pattern: processFilter.pattern) { pgrepResult in
            do {
                let pids = try pgrepResult.get()
                pcpu(pids: pids, completion: { (pcpuResult) in
                    guard let pcpus = try? pcpuResult.get() else {
                        fatalError()
                    }
                    driver.process(pcpus: pcpus)
                })
            } catch {
                fatalError("\(error)")
            }
        }
    }
}
