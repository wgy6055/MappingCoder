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

    private let keyword: KeywordType
    private let type: String
    private let isOptional: Bool

    let name: String
    /// nested JSON value which can be converted, maybe nil
    var nestedJSONValue: [String : Any]?

    init(
        name: String,
        jsonValue: Any,
        keyword: KeywordType,
        isOptional: Bool
    ) {
        self.keyword = keyword
        self.isOptional = isOptional
        self.name = name
        (type, nestedJSONValue) = valueType(
            of: jsonValue,
            propertyName: name
        )
    }
}

extension PropertyDeclaration: CustomStringConvertible {

    var description: String {
        let hasDefault = (!isOptional && keyword == .var)
        return "\(keyword) \(name): \(type)\(isOptional ? "?" : "")\(hasDefault ? " = <#defaultValue#" + ">" : "")"
    }
}

fileprivate func valueType(
    of value: Any,
    propertyName: String
) -> (String, [String : Any]?) {

    switch value {
    case let number as NSNumber:
        var type = number.valueType
        if type == "Int", propertyName.endWithID {
            type = "Int64"
        }
        return (type, nil)
    case _ as String:
        return ("String", nil)
    case let array as [Any]:
        let result = valueType(of: array.first as Any, propertyName: propertyName)
        return ("[\(result.0)]", result.1)
    case let json as [String : Any]:
        return ("<#NestedType#" + ">", json)
    default:
        return ("<#SomeType#" + ">", nil)
    }
}
