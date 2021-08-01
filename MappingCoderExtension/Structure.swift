//
//  Structure.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/1.
//

import Foundation
import SwiftSyntax

struct Structure: TopLevelDeclaration {

    private(set) var name: String = ""
    private(set) var inheritance: [String] = []
    private(set) var variables: [Variable] = []

    var protocolType: ProtocolType? {
        inheritance.first {
            ProtocolType(rawValue: $0) != nil
        }.flatMap { ProtocolType(rawValue: $0) }
    }
}

extension Structure: ExpressibleBySyntax {

    init(_ node: StructDeclSyntax) {
        name = node.identifier.text
        inheritance = node.inheritanceClause?.inheritedTypeCollection.map {
            $0.typeName.description.trimmed
        } ?? []
        node.members.members.forEach {
            $0.children.forEach {
                guard let declaration = $0.asProtocol(DeclSyntaxProtocol.self) else {
                    return
                }
                if let variable = declaration as? VariableDeclSyntax {
                    variables.append(contentsOf: Variable.variables(from: variable))
                }
            }
        }
    }
}
