//
//  Logic.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 08/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

typealias Samples = Int

class Driver {
    
    init(cpuUsageThreshold: Int, samplesThreshold: Int, action: @escaping (PID) -> Void) {
        self.cpuUsageThreshold = cpuUsageThreshold
        self.samplesThreshold = samplesThreshold
        self.action = action
    }
    
    func process(_ stats: [PID:CPUUsage]) {
        dump(monitoredPIDs, name: "oldMonitoredPIDs")
        dump(stats, name: "stats", maxDepth: 0)
        let cpuUsageExceedingStats = stats.filter { (_, cpuUsage) in cpuUsage > cpuUsageThreshold }
        dump(cpuUsageExceedingStats, name: "cpuUsageExceedingStats")
        let obsoletedPIDs = monitoredPIDs.keys.filter { !cpuUsageExceedingStats.keys.contains($0) }
        dump(obsoletedPIDs, name: "obsoletedPIDs")
        let newPIDs = cpuUsageExceedingStats.keys.filter { !monitoredPIDs.keys.contains($0) }
        dump(newPIDs, name: "newPIDs")
        obsoletedPIDs.forEach {
            monitoredPIDs.removeValue(forKey: $0)
        }
        monitoredPIDs.forEach { (_, ageInfo: AgeInfo) in ageInfo.samplesOld += 1 }
        newPIDs.forEach {
            monitoredPIDs[$0] = AgeInfo(samplesOld: 1)
        }
        dump(monitoredPIDs, name: "monitoredPIDs")
        for (targetPid, ageInfo) in monitoredPIDs where ageInfo.samplesOld > samplesThreshold {
            dump(targetPid, name: "targetPid")
            action(targetPid)
        }
    }
    
    private let cpuUsageThreshold: Int
    private let samplesThreshold: Int
    private let action: (PID) -> Void
    
    private var monitoredPIDs: [PID:AgeInfo] = [:]
}

private class AgeInfo {
    var samplesOld: Samples
    init(samplesOld: Samples) {
        self.samplesOld = samplesOld
    }
}
