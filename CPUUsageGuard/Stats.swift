//
//  Stats.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 08/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

struct ProcessFilter {
    let pattern: String
    let topDelay: Int
}

typealias CPUUsage = Int

func statsFor(_ processFilter: ProcessFilter, completion: @escaping (Result<[PID:CPUUsage], Error>) -> Void) {
    let process = Process()
    
    let standardOutputPipe = Pipe()
    let standardErrorPipe = Pipe()
    
    let topDelay = processFilter.topDelay
    let pattern = processFilter.pattern
    
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = [
        "-c",
        "top -l 2 -s \(topDelay) -stats pid,cpu $(pgrep -f '\(pattern)'|while read i; do echo -pid \"$i\"; done)|perl -e'print reverse<>'|sed -e '/^PID/,$ d'"
    ]
    process.standardOutput = standardOutputPipe
    process.standardError = standardErrorPipe
    process.terminationHandler = { process in
        completion(.init() {
            try processTerminatedProcess(process, standardOutputPipe: standardOutputPipe, standardErrorPipe: standardErrorPipe)
            })
    }
    
    try! process.run()
}

private func processTerminatedProcess(_ process: Process, standardOutputPipe: Pipe, standardErrorPipe: Pipe) throws -> [PID:CPUUsage] {
    do {
        let terminationReason = process.terminationReason
        enum Error: Swift.Error {
            case badTerminationReason(Process.TerminationReason)
            case badTerminationStatus(Int32)
        }
        guard case .exit = terminationReason else {
            throw Error.badTerminationReason(terminationReason)
        }
        let terminationStatus = process.terminationStatus
        guard 0 == terminationStatus else {
            throw Error.badTerminationStatus(terminationStatus)
        }
        let data = standardOutputPipe.fileHandleForReading.readDataToEndOfFile()
        let linesCombined = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .controlCharacters)
        let lines = linesCombined.split(separator: "\n")
        let result: [PID:CPUUsage] = lines.reduce([:]) { (acc, line) in
            let components = line.split(separator: " ")
            let pid = Int32(components[0])!
            let cpu = Int(Float(components[1])!)
            var r = acc
            r[pid] = cpu
            return r
        }
        return result
    } catch {
        let standardErrorData = standardErrorPipe.fileHandleForReading.readDataToEndOfFile()
        dump(standardErrorData, name: "standardErrorData")
        throw error
    }
}
