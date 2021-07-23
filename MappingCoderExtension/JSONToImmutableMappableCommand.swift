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
                        NSLocalizedDescriptionKey :
"""
Fail to parse JSON.\
Please select JSON from source editor and try again. 🚨
"""
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
        do {
            try convert(
                json: json,
                to: .class, // TODO: support config
                in: invocation.buffer,
                conformTo: .immutableMappable
            )
        } catch let error {
            completionHandler(error)
        }

        completionHandler(nil)
    }
}
