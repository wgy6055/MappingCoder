//
//  SettingsCommand.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/2.
//

import Foundation
import XcodeKit
import AppKit

class SettingsCommand: NSObject,
                       XCSourceEditorCommand {

    func perform(
        with invocation: XCSourceEditorCommandInvocation,
        completionHandler: @escaping (Error?) -> Void
    ) {

        if #available(macOS 10.15, *) {
            NSWorkspace.shared.openApplication(
                at: URL(fileURLWithPath: "/Applications/MappingCoder.app"),
                configuration: NSWorkspace.OpenConfiguration()
            )
        } else {
            NSWorkspace.shared.launchApplication(
                withBundleIdentifier: "com.wgy.MappingCoder",
                additionalEventParamDescriptor: nil,
                launchIdentifier: nil
            )
        }

        completionHandler(nil)
    }
}
