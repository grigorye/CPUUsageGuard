//
//  Stats.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 08/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation
import Darwin

struct ProcessFilter {
    let pattern: String
    let topDelay: Int
}

typealias CPUUsage = Int32

func CPUUsageFor(pid: pid_t) throws -> Int32 {
    enum Error: Swift.Error {
        case failed_task_for_pid(kr: Int32, pid: Int32)
        case failed_proc_pidinfo(e: Int32, pid: Int32)
    }
    
    try acquireTaskportRight()
    
    var task: task_t = .init()
    let kr = task_for_pid(mach_task_self_, pid, &task)
    guard kr == KERN_SUCCESS else {
        print(String(cString: mach_error_string(kr)))
        throw Error.failed_task_for_pid(kr: kr, pid: pid)
    }
    
    var info: proc_threadinfo = .init()
    do {
        let error = proc_pidinfo(pid, PROC_PIDTHREADINFO, 1, &info, Int32(MemoryLayout.size(ofValue: info)))
        guard error == 0 else {
            throw Error.failed_proc_pidinfo(e: error, pid: pid)
        }
    }
    let cpu_usage = info.pth_cpu_usage
    dump(info)
    if cpu_usage > 0 {
        _ = cpu_usage
    }
    return cpu_usage
}

func acquireTaskportRight() throws {
    try "system.privilege.taskport:".data(using: .utf8)?.withUnsafeBytes({ (bytes: UnsafePointer<Int8>) -> Void in
        var taskPortItem = AuthorizationItem(name: bytes, valueLength: 0, value: nil, flags: 0)
        var rights = AuthorizationRights(count: 1, items: &taskPortItem)
        var author: AuthorizationRef?
        let authFlags: AuthorizationFlags = [.extendRights, .preAuthorize, .interactionAllowed, AuthorizationFlags(rawValue: AuthorizationFlags.RawValue(1 << 5))]
        do {
            let status = AuthorizationCreate(nil, nil, authFlags, &author)
            
            enum Error: Swift.Error {
                case AuthorizationCreateFailure(OSStatus)
            }
            guard status == errAuthorizationSuccess else {
                throw Error.AuthorizationCreateFailure(status)
            }
        }
        do {
            var outRightsRef: UnsafeMutablePointer<AuthorizationRights>?
            let status = AuthorizationCopyRights(author!, &rights, nil, authFlags, &outRightsRef)
            enum Error: Swift.Error {
                case AuthorizationCreateFailure(OSStatus)
            }
            guard status == errAuthorizationSuccess else {
                throw Error.AuthorizationCreateFailure(status)
            }
        }
    })
}
