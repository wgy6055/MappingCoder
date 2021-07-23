//
//  PropertyDeclaration.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/22.
//

import Foundation

struct PropertyDeclaration {

    enum KeywordType: String {
        case `let` = "let"
        case `var` = "var"
    }

    let keyword: KeywordType
    let name: String
    let type: String
    let isOptional: Bool

    init(
        name: String,
        jsonValue: Any,
        keyword: KeywordType,
        isOptional: Bool
    ) {
        self.keyword = keyword
        self.isOptional = isOptional
        self.name = name
        type = valueType(of: jsonValue)
    }
}

extension PropertyDeclaration: CustomStringConvertible {

    var description: String {
        let hasDefault = (!isOptional && keyword == .var)
        return "\(keyword) \(name): \(type)\(isOptional ? "?" : "")\(hasDefault ? " = <#defaultValue#" + ">" : "")"
    }
}

fileprivate func valueType(of value: Any) -> String {
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
