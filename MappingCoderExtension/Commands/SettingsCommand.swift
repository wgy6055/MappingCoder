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

        NSWorkspace.shared.openApplication(
            at: URL(fileURLWithPath: "/Applications/MappingCoder.app"),
            configuration: NSWorkspace.OpenConfiguration()
        )

        completionHandler(nil)
    }
}
