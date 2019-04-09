//
//  pgrep.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 08/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

func pgrep(pattern: String, completion: @escaping (Result<[pid_t], Error>) -> Void) {
    exec("/usr/bin/pgrep", ["-f", pattern]) { (pgrepResult) in
        completion(.init(catching: {
            let lines = try pgrepResult.get()
            let result: [pid_t] = try lines.map { (line) in
                enum Error: Swift.Error {
                    case pgrepOuptutParseFailure(line: String)
                }
                guard let pid = pid_t(line) else {
                    throw Error.pgrepOuptutParseFailure(line: line)
                }
                return pid
            }
            return result
        }))
    }
}
