//
//  Extension.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/19.
//

import Foundation
import XcodeKit

extension String {

    func substring(from idx: Int) -> String {
        guard idx < count else {
            return ""
        }
        let start = index(startIndex, offsetBy: idx)
        return String(self[start...])
    }

    func substring(to idx: Int) -> String {
        guard idx < count else {
            return self
        }
        let end = index(startIndex, offsetBy: idx)
        return String(self[...end])
    }

    func substring(from: Int, to: Int) -> String {
        guard from <= to else {
            return ""
        }
        let safeFrom = max(from, 0)
        let safeTo = min(to, count - 1)
        let start = index(startIndex, offsetBy: safeFrom)
        let end = index(startIndex, offsetBy: safeTo)
        return String(self[start...end])
    }

    var toJSONObject: [String : Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String : Any]
    }

    var fullRange: NSRange {
        NSRange(startIndex..., in: self)
    }

    var endWithID: Bool {
        guard let regex = try? NSRegularExpression(pattern: "^\\w*(Id|ID|id)$") else {
            return false
        }
        return regex.firstMatch(in: self, range: fullRange) != nil
    }

    var trimmed: String {
        let startIndex = firstIndex(where: { !$0.isWhitespace }) ?? self.startIndex
        let endIndex = lastIndex(where: { !$0.isWhitespace }) ?? self.endIndex
        return String(self[startIndex...endIndex])
    }

    var unindented: String {
        let lines = split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count > 1 else { return trimmingCharacters(in: .whitespaces) }

        let indentation = lines.compactMap { $0.firstIndex(where: { !$0.isWhitespace })?.utf16Offset(in: $0) }
            .min() ?? 0

        return lines.map {
            guard $0.count > indentation else { return String($0) }
            return String($0.suffix($0.count - indentation))
        }.joined(separator: "\n")
    }

    var asPlaceholder: String {
        "<#\(self)#" + ">"
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

extension Character {

    /// Characters that cause the next character to be capitalized.
    fileprivate static let removableCharacters: [Character] = [" ", "_", "-"]

    /// Returns whether this causes the next character to be capitalized.
    fileprivate var isRemovable: Bool {
        Character.removableCharacters.contains(self)
    }
}

extension String {

    /// Returns a camelCase version of this string with spaces, dashes and underscores removed.
    /// Each space in the name denotes a new capitalized word.
    var camelCase: String {

        guard !isEmpty else {
            return self
        }
        var newString = ""
        var capitalizeNext = false
        for character in self {
            if capitalizeNext {
                newString += character.uppercased()
                capitalizeNext = false
            } else if character.isRemovable {
                capitalizeNext = true
            } else {
                newString += String(character)
            }
        }

        return newString
    }
}

extension Array where Element == String {

    func subString(from: XCSourceTextPosition, to: XCSourceTextPosition) -> String {
        let startLine = self[from.line]
        if from.line == to.line {
            return startLine.substring(from: from.column, to: to.column)
        }
        var substring = ""
        let targetLines = Array(self[from.line...to.line])
        for i in (0..<targetLines.count) {
            let line = targetLines[i]
            if i == 0 {
                substring += line.substring(from: from.column)
            } else if i == targetLines.count - 1 {
                substring += line.substring(to: to.column)
            } else {
                substring += line
            }
        }
        return substring
    }
}

extension Collection {

    func index(of index: Index) -> Int {
        distance(from: startIndex, to: index)
    }
}
