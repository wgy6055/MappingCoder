//
//  Indentation.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/20.
//

import Foundation

struct Indentation {

    let useTabs: Bool
    let indentationWidth: Int
    let level: Int
    let indentPerLevel: String

    init(useTabs: Bool, indentationWidth: Int, level: Int = 0) {
        self.useTabs = useTabs
        self.indentationWidth = indentationWidth
        self.level = level
        self.indentPerLevel = useTabs ? "\t" : String(repeating: " ", count: indentationWidth)
    }

    private init(useTabs: Bool, indentationWidth: Int, level: Int, indentPerLevel: String) {
        self.useTabs = useTabs
        self.indentationWidth = indentationWidth
        self.level = level
        self.indentPerLevel = indentPerLevel
    }

    func indent() -> Indentation {
        Indentation(
            useTabs: useTabs,
            indentationWidth: indentationWidth,
            level: level + 1,
            indentPerLevel: indentPerLevel
        )
    }
}

extension Indentation: CustomStringConvertible {

    var description: String {
        String(repeating: indentPerLevel, count: level)
    }
}
