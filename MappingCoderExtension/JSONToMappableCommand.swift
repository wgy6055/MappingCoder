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

        invocation.buffer.trimTail()

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
            try convert(json: json, in: invocation.buffer)
        } catch let error {
            completionHandler(error)
        }
        
        completionHandler(nil)
    }
    
}

extension JSONToMappableCommand {

    private func json(from buffer: XCSourceTextBuffer) -> [String : Any]? {

        let selections = buffer.selections
        guard let lines = buffer.lines as? [String] else {
            return nil
        }
        let jsonString = selections.reduce("") { string, selection in
            guard let range = selection as? XCSourceTextRange,
                  range.start.line <= range.end.line else {
                return string
            }
            func sourceCode(from: XCSourceTextPosition, to: XCSourceTextPosition) -> String {
                let startLine = lines[from.line]
                if from.line == to.line {
                    return startLine.substring(from: from.column, to: to.column)
                }
                var sourceCode = ""
                let targetLines = Array(lines[from.line...to.line])
                for i in (0..<targetLines.count) {
                    let line = targetLines[i]
                    if i == 0 {
                        sourceCode += line.substring(from: from.column)
                    } else if i == targetLines.count - 1 {
                        sourceCode += line.substring(to: to.column)
                    } else {
                        sourceCode += line
                    }
                }
                return sourceCode
            }
            return string + sourceCode(from: range.start, to: range.end)
        }

        return jsonString.trimmingCharacters(in: .whitespacesAndNewlines).toJSONObject
    }

    private func commentSelectios(in buffer: XCSourceTextBuffer) {

        let selections = buffer.selections
        selections.forEach { selection in
            guard let range = selection as? XCSourceTextRange else {
                return
            }
            for i in (range.start.line...range.end.line) {
                guard var line = buffer.lines[i] as? String else {
                    return
                }
                line = "//" + line
                buffer.lines.replaceObject(at: i, with: line)
            }
        }
    }

    private func convert(json: [String : Any], in buffer: XCSourceTextBuffer) throws {

        let fileIndent = Indentation(
            useTabs: buffer.usesTabsForIndentation,
            indentationWidth: buffer.indentationWidth
        )
        let classIndent = fileIndent.indent()
        let funcIndent = classIndent.indent()

        var lines: [String] = [""]
        lines.append("class <#name#" + ">: Mappable {")
        lines.append("")

        lines += json.map {
            "\(classIndent)var \($0): \(valueType(of: $1)) = <#defaultValue#" + ">"
        }
        lines.append("")

        lines.append("\(classIndent)required init?(map: Map) {}")
        lines.append("")

        lines.append("\(classIndent)func mapping(map: Map) {")
        lines += json.keys.map {
            "\(funcIndent)\($0) <- map[\"\($0)\"]"
        }
        lines.append("\(classIndent)}")

        lines.append("}")

        guard let selectionTrail = buffer.selections.lastObject as? XCSourceTextRange else {
            throw NSError(domain: domain, code: -1, userInfo: nil)
        }
        let codeStartLine = selectionTrail.end.line + 1
        lines.reversed().forEach {
            buffer.lines.insert($0, at: codeStartLine)
        }
    }

    private func valueType(of value: Any) -> String {
        switch value {
        case let number as NSNumber:
            return number.valueType
        case _ as String:
            return "String"
        case _ as [Any]:
            return "[<#SomeType#" + ">]"
        default:
            return "<#SomeType#" + ">"
        }
    }
}

extension XCSourceTextBuffer {

    /// {line: x, column: 0} -> {line: x - 1, column: y},
    /// to avoid "Out of Range" when access lines
    func trimTail() {
        selections.forEach { selection in
            guard let range = selection as? XCSourceTextRange,
                  range.end.column == 0,
                  let previousLine = lines[range.end.line - 1] as? String else {
                return
            }
            range.end = XCSourceTextPosition(line: range.end.line - 1, column: previousLine.count)
        }
    }
}

extension NSNumber {

    var valueType: String {
        if type(of: self) == type(of: NSNumber(value: true)) {
            return "Bool"
        } else if self is Int {
            return "Int"
        } else {
            return "Double"
        }
    }
}
