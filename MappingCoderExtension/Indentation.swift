//
//  Indentation.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/20.
//

import Foundation

struct Indentation {

    let level: Int
    let indentPerLevel: String

    init(useTabs: Bool, indentationWidth: Int, level: Int = 0) {
        self.level = level
        self.indentPerLevel = useTabs ? "\t" : String(repeating: " ", count: indentationWidth)
    }

    private init(level: Int, indentPerLevel: String) {
        self.level = level
        self.indentPerLevel = indentPerLevel
    }

    func indent() -> Indentation {
        Indentation(level: level + 1, indentPerLevel: indentPerLevel)
    }
}

extension Indentation: CustomStringConvertible {

    var description: String {
        String(repeating: indentPerLevel, count: level)
    }
}
