//
//  Visitor.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/1.
//

import Foundation
import SwiftSyntax

class Visitor: SyntaxVisitor {

    var topLevels: [TopLevelDeclaration] = []

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        topLevels.append(Class(node))
        return .visitChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        topLevels.append(Structure(node))
        return .visitChildren
    }
}
