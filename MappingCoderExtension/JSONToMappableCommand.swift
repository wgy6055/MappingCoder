//
//  JSONToMappableCommand.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/19.
//

import Foundation
import XcodeKit

let domain = "com.wgy.MappingCoder.error"

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
                conformTo: .mappable
            )
        } catch let error {
            completionHandler(error)
        }
        
        completionHandler(nil)
    }
    
}
