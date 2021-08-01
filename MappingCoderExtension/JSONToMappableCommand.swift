//
//  JSONToMappableCommand.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/19.
//

import Foundation
import XcodeKit

class JSONToMappableCommand: NSObject, XCSourceEditorCommand {
    
    func perform(
        with invocation: XCSourceEditorCommandInvocation,
        completionHandler: @escaping (Error?) -> Void
    ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.

        invocation.buffer.trimSelectionsTail()

        guard let json = json(from: invocation.buffer) else {
            completionHandler(
                NSError(
                    domain: domain,
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey : parseJSONFailed
                    ]
                )
            )
            return
        }
        guard !json.isEmpty else {
            completionHandler(nil)
            return
        }
        invocation.buffer.commentSelections()

        guard let selectionTrail = invocation.buffer.selections.lastObject as? XCSourceTextRange else {
            completionHandler(NSError(domain: domain, code: -1, userInfo: nil))
            return
        }
        let startLine = selectionTrail.end.line + 1
        convert(
            json: json,
            to: .class, // TODO: support config
            in: invocation.buffer,
            at: startLine,
            conformTo: .mappable
        )
        
        completionHandler(nil)
    }
    
}
