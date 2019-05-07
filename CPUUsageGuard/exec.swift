//
//  exec.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 09/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

func exec(_ path: String, _ arguments: [String], completion: @escaping (Result<[String], Error>) -> Void) {
    let process = Process()
    
    let standardOutputPipe = Pipe()
    let standardErrorPipe = Pipe()
    
    process.executableURL = URL(fileURLWithPath: path)
    process.arguments = arguments
    process.standardOutput = standardOutputPipe
    process.standardError = standardErrorPipe
    process.terminationHandler = { process in
        completion(.init(catching: {
            try parseResultFromTerminated(process, standardOutputPipe: standardOutputPipe, standardErrorPipe: standardErrorPipe)
        }))
    }
    
    try! process.run()
}

private func parseResultFromTerminated(_ process: Process, standardOutputPipe: Pipe, standardErrorPipe: Pipe) throws -> [String] {
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
        let linesCombined = String(data: data, encoding: .utf8)!
        let lines = linesCombined.split(separator: "\n").map {String($0)}
        return lines
    } catch {
        let standardErrorData = standardErrorPipe.fileHandleForReading.readDataToEndOfFile()
        dump(String(data: standardErrorData, encoding: .utf8) ?? "", name: "standardError")
        throw error
    }
}
