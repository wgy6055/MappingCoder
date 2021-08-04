//
//  Variable.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/1.
//

import Foundation
import SwiftSyntax

struct Variable {

    /// The name of the property or top-level variable or constant.
    let name: String

    let optional: Bool

    let isConstant: Bool

    var key: String

    var defaultValue: String
}

extension Variable: ExpressibleBySyntax {
    /**
     Creates and returns variables from a variable declaration,
     which may contain one or more pattern bindings,
     such as `let x: Int = 1, y: Int = 2`.
     */
    public static func variables(from node: VariableDeclSyntax) -> [Variable] {
        return node.bindings.compactMap { Variable($0) }
    }

    /// Creates an instance initialized with the given syntax node.
    public init?(_ node: PatternBindingSyntax) {
        guard let parent = node.nearestDecl as? VariableDeclSyntax else {
            preconditionFailure("PatternBindingSyntax should be contained within VariableDeclSyntax")
            return nil
        }

        name = node.pattern.description.trimmed
        optional = node.typeAnnotation?.type.asProtocol(TypeSyntaxProtocol.self) is OptionalTypeSyntax
        isConstant = parent.letOrVarKeyword.text == "let" && node.initializer != nil
        // find a lineComment for variable
        let lineComment: String?
        if let comment = parent.attributes?.first?.lineComment {
            lineComment = comment
        } else if let comment = parent.modifiers?.first?.lineComment {
            lineComment = comment
        } else if let comment = parent.letOrVarKeyword.lineComment {
            lineComment = comment
        } else {
            lineComment = nil
        }
        guard let source = lineComment,
              let tree = try? SyntaxParser.parse(source: source) else {
            key = name
            defaultValue = "defaultValue".asPlaceholder
            return
        }

        let parser = AttributeParser()
        parser.walk(tree)

        if let key = parser.key,
           !key.isEmpty {
            self.key = key
        } else {
            key = name
        }
        if let defaultValue = parser.defaultValue,
           !defaultValue.isEmpty {
            self.defaultValue = defaultValue
        } else {
            defaultValue = "defaultValue".asPlaceholder
        }
    }
}
