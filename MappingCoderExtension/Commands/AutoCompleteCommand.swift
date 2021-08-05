//
//  AutoCompleteCommand.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/30.
//

import Foundation
import XcodeKit
import SwiftSyntax

class AutoCompleteCommand: NSObject,
                           XCSourceEditorCommand {

    func perform(
        with invocation: XCSourceEditorCommandInvocation,
        completionHandler: @escaping (Error?) -> Void
    ) {
        invocation.buffer.trimSelectionsTail()

        let buffer = invocation.buffer
        guard let selections = buffer.selections as? [XCSourceTextRange],
              let startLine = selections.first?.start.line else {
            completionHandler(NSError(domain: domain, code: -1, userInfo: nil))
            return
        }
        let source = buffer.joinedSelectedString
        let visitor = Visitor()
        guard let tree = try? SyntaxParser.parse(source: source) else {
            completionHandler(
                NSError(
                    domain: domain,
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey : parseSyntaxFailed
                    ]
                )
            )
            return
        }

        visitor.walk(tree)
        let topLevels = visitor.topLevels
        guard topLevels.count > 0 else {
            completionHandler(
                NSError(
                    domain: domain,
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey : parseSyntaxFailed
                    ]
                )
            )
            return
        }

        var result = Syntax(tree)
        topLevels.forEach {
            let rewriter = Rewriter(
                topLevel: $0,
                useTabs: buffer.usesTabsForIndentation,
                indentationWidth: buffer.indentationWidth
            )
            result = rewriter.visit(result)
        }

        selections.forEach {
            buffer.lines.removeObjects(
                in: NSRange(location: $0.start.line, length: $0.end.line - $0.start.line + 1)
            )
        }

        let resultArray = "\(result)".components(separatedBy: .newlines)
        resultArray.reversed().forEach {
            buffer.lines.insert($0, at: startLine)
        }

        completionHandler(nil)
    }
}
