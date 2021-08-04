//
//  Class.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/1.
//

import Foundation
import SwiftSyntax

struct Class: TopLevelDeclaration {

    private(set) var name: String = ""
    private(set) var inheritance: [String] = []
    private(set) var variables: [Variable] = []
    private(set) var isPublic: Bool = false

    var protocolType: ProtocolType? {
        inheritance.first {
            ProtocolType(rawValue: $0) != nil
        }.flatMap { ProtocolType(rawValue: $0) }
    }
}

extension Class: ExpressibleBySyntax {

    init(_ node: ClassDeclSyntax) {
        name = node.identifier.text
        inheritance = node.inheritanceClause?.inheritedTypeCollection.map {
            $0.typeName.description.trimmed
        } ?? []
        isPublic = node.modifiers?.hasPublic ?? false
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
