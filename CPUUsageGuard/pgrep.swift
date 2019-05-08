//
//  pgrep.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 08/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

func pgrep(pattern: String, completion: @escaping (Result<[pid_t], Error>) -> Void) {
    let command = "pgrep -f \"\(pattern)\"; case $? in 0|1) exit 0 ;; *) exit $?; esac"
    exec("/bin/sh", ["-c", command]) { (shellResult) in
        completion(.init(catching: {
            let lines = try shellResult.get()
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
