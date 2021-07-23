//
//  MappingExpression.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/23.
//

import Foundation

struct MappingExpression {

    let name: String
    let `operator`: String
    let key: String

    init(name: String, key: String, protocolType: ProtocolType) {
        self.name = name
        self.key = key
        self.operator = protocolType == .mappable ? "<-" : ">>>"
    }
}

extension MappingExpression: CustomStringConvertible {

    var description: String {
        "\(name) \(`operator`) map[\"\(key)\"]"
    }
}
