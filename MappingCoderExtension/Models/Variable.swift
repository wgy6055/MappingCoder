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

    let lineComment: String?

    var key: String {
        guard let match = attributeMatch else {
            return name
        }
        let keyRange = match.range(withName: "key")
        return lineComment?.substring(
            from: keyRange.location,
            to: keyRange.location + keyRange.length - 1
        ) ?? name
    }

    var defaultValue: String {
        guard let match = attributeMatch else {
            return name
        }
        let defaultRange = match.range(withName: "defaultValue")
        return lineComment?.substring(
            from: defaultRange.location,
            to: defaultRange.location + defaultRange.length - 1
        ) ?? "defaultValue".asPlaceholder
    }


    private var attributeMatch: NSTextCheckingResult? {
        guard let lineComment = lineComment,
              let regex = try? NSRegularExpression(
                pattern: "@map\\(\\s*key\\s*:\\s*(?<key>.+)\\s*,\\s*default\\s*:\\s*(?<defaultValue>(\\w|\"|\\.)*)\\s*\\)"
              ) else {
            return nil
        }
        return regex.firstMatch(
            in: lineComment,
            range: lineComment.fullRange
        )
    }
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
        if let comment = parent.attributes?.first?.lineComment {
            lineComment = comment
        } else if let comment = parent.modifiers?.first?.lineComment {
            lineComment = comment
        } else if let comment = parent.letOrVarKeyword.lineComment {
            lineComment = comment
        } else {
            lineComment = nil
        }
    }
}
