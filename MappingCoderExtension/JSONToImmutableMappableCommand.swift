//
//  JSONToImmutableMappableCommand.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/22.
//

import Foundation
import XcodeKit

class JSONToImmutableMappableCommand: NSObject,
                                      XCSourceEditorCommand {

    func perform(
        with invocation: XCSourceEditorCommandInvocation,
        completionHandler: @escaping (Error?) -> Void
    ) {
        invocation.buffer.trimSelectionsTail()

        guard let json = json(from: invocation.buffer) else {
            completionHandler(
                NSError(
                    domain: domain,
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey : paseJSONFailed
                    ]
                )
            )
            return
        }
        guard !json.isEmpty else {
            completionHandler(nil)
            return
        }
        commentSelectios(in: invocation.buffer)

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
            conformTo: .immutableMappable
        )

        completionHandler(nil)
    }
}
