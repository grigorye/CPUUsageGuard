//
//  PCPU.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 09/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

func pcpu(pids: [pid_t], completion: @escaping (Result<[pid_t : Float], Error>) -> Void) {
    let pidsArg = pids.map {String($0)}.joined(separator: ",")
    let command = "ps -o pid,pcpu -p \(pidsArg) | tail -n +2"
    exec("/bin/sh", ["-c", command]) { (shellResult) in
        completion(.init(catching: {
            let lines = try shellResult.get()
            let result: [pid_t : Float] = try lines.reduce([:]) { (acc, line) in
                enum Error: Swift.Error {
                    case psOuptutParseFailure(line: String)
                }
                let components = line.split(separator: " ")
                guard components.count == 2 else {
                    throw Error.psOuptutParseFailure(line: line)
                }
                guard let pid = pid_t(components[0]) else {
                    throw Error.psOuptutParseFailure(line: line)
                }
                guard let pcpu = Float(components[1]) else {
                    throw Error.psOuptutParseFailure(line: line)
                }
                var acc = acc
                acc[pid] = pcpu
                return acc
            }
            return result
        }))
    }
}
