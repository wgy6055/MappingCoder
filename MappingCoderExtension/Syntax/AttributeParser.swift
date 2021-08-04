//
//  AttributeParser.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/4.
//

import Foundation
import SwiftSyntax

/// Parse custom attribute syntax from line comment.
/// eg. @map(key: "name", default: "")
/// eg. @map(key: "name")
/// eg. @map(default: "")
class AttributeParser: SyntaxVisitor {

    var key: String?
    var defaultValue: String?

    override func visit(_ node: CustomAttributeSyntax) -> SyntaxVisitorContinueKind {
        guard let name = node.attributeName.asProtocol(TypeSyntaxProtocol.self)
                as? SimpleTypeIdentifierSyntax,
              name.name.text == "map" else {
            return .skipChildren
        }

        node.argumentList?.forEach {
            if $0.label?.text == "key" {
                guard let expr = $0.expression.asProtocol(ExprSyntaxProtocol.self)
                        as? StringLiteralExprSyntax else {
                    return
                }
                key = "\(expr.segments)"
            } else if $0.label?.text == "default" {
                defaultValue = "\($0.expression)"
            }
        }

        return .visitChildren
    }
}
