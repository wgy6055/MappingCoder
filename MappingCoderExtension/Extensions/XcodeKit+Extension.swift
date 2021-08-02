//
//  XcodeKit+Extension.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/2.
//

import Foundation
import XcodeKit

extension XCSourceTextBuffer {

    /// {line: x, column: 0} -> {line: x - 1, column: y},
    /// to convert selctions (start ..< end) into (start...end-1),
    /// so we can walk through selections conveniently
    func trimSelectionsTail() {
        selections.forEach { selection in
            guard let range = selection as? XCSourceTextRange,
                  range.end.column == 0,
                  let previousLine = lines[range.end.line - 1] as? String else {
                return
            }
            range.end = XCSourceTextPosition(line: range.end.line - 1, column: previousLine.count)
        }
    }

    var joinedSelectedString: String {
        guard let selections = selections as? [XCSourceTextRange],
              let lines = lines as? [String] else {
            return ""
        }
        return selections.reduce("") { string, range in
            guard range.start.line <= range.end.line else {
                return string
            }
            return string + lines.subString(from: range.start, to: range.end)
        }
    }

    func commentSelections() {
        selections.forEach { selection in
            guard let range = selection as? XCSourceTextRange,
                  range.start.line <= range.end.line else {
                return
            }
            for i in (range.start.line...range.end.line) {
                guard var line = lines[i] as? String else {
                    return
                }
                line = "//" + line
                lines.replaceObject(at: i, with: line)
            }
        }
    }
}
