//
//  TryMapValueExpression.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/23.
//

import Foundation

struct TryMapValueExpression {

    let name: String
    private let key: String
    private let isOptional: Bool

    init(name: String, key: String, isOptional: Bool) {
        self.name = name
        self.key = key
        self.isOptional = isOptional
    }
}

extension TryMapValueExpression: CustomStringConvertible {

    var description: String {
        var rightValue = "try? map.value(\"\(key)\")"
        if !isOptional {
            rightValue = "(" + rightValue + ")" + " ?? " + "defaultValue".asPlaceholder
        }
        return "\(name) = \(rightValue)"
    }
}
