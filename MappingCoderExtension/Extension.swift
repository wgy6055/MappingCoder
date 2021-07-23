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
}
