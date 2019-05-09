//
//  Notifications.swift
//  CPUUsageGuard
//
//  Created by Grigory Entin on 29/04/2019.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import Foundation

func willKill(pid: pid_t) {
    notify(title: "CPUUsageGuard", message: "Terminating process: \(pid)")
}

func notify(title: String, message: String) {
    let commandComponents = [
        "~/homebrew/bin/terminal-notifier",
        "-message",
        message,
        "-title",
        title
    ]
    let command = commandComponents.joined(separator: " ") // TODO: add shell escaping
    exec("/bin/sh", ["-c", command]) { (shellResult) in
        dump(shellResult, name: "notifyShellResult")
    }
}
