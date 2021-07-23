//
//  TryMapValueExpression.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/23.
//

import Foundation

struct TryMapValueExpression {

    let name: String
    let key: String
    let isOptional: Bool
}

extension TryMapValueExpression: CustomStringConvertible {

    var description: String {
        var rightValue = "try? map.value(\"\(key)\")"
        if !isOptional {
            rightValue = "(" + rightValue + ")" + " ?? <#defaultValue#" + ">"
        }
        return "\(name) = \(rightValue)"
    }
}
