//
//  SwiftSyntax+Extension.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/1.
//

import Foundation
import SwiftSyntax

extension SyntaxProtocol {
    var nearestDecl: DeclSyntaxProtocol? {
        for case let node? in sequence(first: parent, next: { $0?.parent }) {
            guard let declaration = node.asProtocol(DeclSyntaxProtocol.self) else { continue }
            return declaration
        }

        return nil
    }

    var nearestTopLevelDecl: DeclSyntaxProtocol? {
        for case let node? in sequence(first: parent, next: { $0?.parent }) {
            guard let declaration = node.asProtocol(DeclSyntaxProtocol.self) as? ClassDeclSyntax else {
                guard let declaration = node.asProtocol(DeclSyntaxProtocol.self) as? StructDeclSyntax else {
                    continue
                }
                return declaration
            }
            return declaration
        }

        return nil
    }

    var nearestTopLevelName: String? {
        guard let nearestTopLevel = nearestTopLevelDecl else {
            return nil
        }

        if let nearestClass = nearestTopLevel as? ClassDeclSyntax {
            return nearestClass.identifier.text
        } else if let nearestStruct = nearestTopLevel as? StructDeclSyntax {
            return nearestStruct.identifier.text
        }
        return nil
    }

    var lineComment: String? {
        return leadingTrivia?.lineComment
    }
}

extension Trivia {
    var lineComment: String? {
        let components = compactMap { $0.lineComment }
        guard !components.isEmpty else { return nil }
        return components.joined(separator: "\n").unindented
    }
}

fileprivate extension TriviaPiece {
    var lineComment: String? {
        switch self {
        case let .lineComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 2)
            return String(comment.suffix(from: startIndex))
        case let .docBlockComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 3)
            let endIndex = comment.index(comment.endIndex, offsetBy: -2)
            return String(comment[startIndex ..< endIndex])
        default:
            return nil
        }
    }
}

extension ParameterClauseSyntax {

    var hasMap: Bool {
        guard let firstParameter = parameterList.first,
              firstParameter.firstName?.text == "map",
              let type = firstParameter.type?.asProtocol(TypeSyntaxProtocol.self)
                as? SimpleTypeIdentifierSyntax,
              type.name.text == "Map" else {
            return false
        }
        return true
    }
}

extension FunctionDeclSyntax {

    var isMapping: Bool {
        identifier.text == "mapping" && signature.input.hasMap
    }
}

extension InitializerDeclSyntax {

    func isInitMap(modelType: ModelType, protocolType: ProtocolType) -> Bool {
        let isClass = modelType == .class
        let isMappable = protocolType == .mappable

        return (isClass ? hasModifierRequired : true)
            && (isMappable ? hasOptionalMark : true)
            && (isMappable ? true : hasThrowsKeyword)
    }

    private var hasModifierRequired: Bool {

        guard let modifiers = modifiers,
              modifiers.contains(where: { $0.name.text == "required" }) else {
            return false
        }
        return true
    }

    private var hasOptionalMark: Bool { optionalMark != nil }

    private var hasThrowsKeyword: Bool {

        guard let keyword = throwsOrRethrowsKeyword,
              keyword.text == "throws" else {
            return false
        }
        return true
    }
}

extension SequenceExprSyntax {

    static func buildInitExpr(
        variable: Variable,
        indentation: Indentation
    ) -> SequenceExprSyntax {

        SequenceExprSyntax { builder in
            builder.addElement(ExprSyntax(IdentifierExprSyntax { builder in
                builder.useIdentifier(
                    SyntaxFactory.makeIdentifier(
                        variable.name,
                        leadingTrivia: .newline + .indent(from: indentation),
                        trailingTrivia: .space
                    )
                )
            }))
            builder.addElement(ExprSyntax(AssignmentExprSyntax { builder in
                builder.useAssignToken(SyntaxFactory.makeEqualToken(trailingTrivia: .space))
            }))

            let tryExpr = ExprSyntax(SyntaxFactory.makeTryExpr(tryKeyword: SyntaxFactory.makeTryKeyword(), questionOrExclamationMark: SyntaxFactory.makePostfixQuestionMarkToken(trailingTrivia: .space), expression: ExprSyntax(SyntaxFactory.makeFunctionCallExpr(
                calledExpression: ExprSyntax(MemberAccessExprSyntax { builder in
                    builder.useBase(ExprSyntax(SyntaxFactory.makeIdentifierExpr(identifier: SyntaxFactory.makeIdentifier("map"), declNameArguments: nil)))
                    builder.useDot(SyntaxFactory.makePeriodToken())
                    builder.useName(SyntaxFactory.makeIdentifier("value"))
                }),
                leftParen: SyntaxFactory.makeLeftParenToken(),
                argumentList: SyntaxFactory.makeTupleExprElementList([
                    TupleExprElementSyntax { builder in
                        builder.useExpression(ExprSyntax(SyntaxFactory.makeStringLiteralExpr(variable.key)))
                    }
                ]),
                rightParen: SyntaxFactory.makeRightParenToken(),
                trailingClosure: nil,
                additionalTrailingClosures: nil
            ))))

            if variable.optional {
                builder.addElement(tryExpr)
            } else {
                builder.addElement(ExprSyntax(SyntaxFactory.makeTupleExpr(
                    leftParen: SyntaxFactory.makeLeftParenToken(),
                    elementList: SyntaxFactory.makeTupleExprElementList([
                        TupleExprElementSyntax { builder in
                            builder.useExpression(ExprSyntax(tryExpr))
                        }
                    ]),
                    rightParen: SyntaxFactory.makeRightParenToken(trailingTrivia: .space)
                )))
                builder.addElement(ExprSyntax(SyntaxFactory.makeBinaryOperatorExpr(
                    operatorToken: SyntaxFactory.makeSpacedBinaryOperator("??", trailingTrivia: .space)
                )))
                builder.addElement(ExprSyntax(SyntaxFactory.makeEditorPlaceholderExpr(
                    identifier: SyntaxFactory.makeIdentifier(variable.defaultValue)
                )))
            }
        }
    }

    static func buildMappingExpr(
        variable: Variable,
        operator: String,
        indentation: Indentation
    ) -> SequenceExprSyntax {
        SequenceExprSyntax { builder in
            builder.addElement(ExprSyntax(IdentifierExprSyntax { builder in
                builder.useIdentifier(
                    SyntaxFactory.makeIdentifier(
                        variable.name,
                        leadingTrivia: .newline + .indent(from: indentation),
                        trailingTrivia: .space
                    )
                )
            }))
            builder.addElement(ExprSyntax(BinaryOperatorExprSyntax { builder in
                builder.useOperatorToken(SyntaxFactory.makeSpacedBinaryOperator(
                    `operator`,
                    trailingTrivia: .space
                ))
            }))
            builder.addElement(ExprSyntax(SubscriptExprSyntax { builder in
                builder.useCalledExpression(ExprSyntax(IdentifierExprSyntax { builder in
                    builder.useIdentifier(SyntaxFactory.makeIdentifier("map"))
                }))
                builder.useLeftBracket(SyntaxFactory.makeLeftSquareBracketToken())
                builder.addArgument(TupleExprElementSyntax { builder in
                    builder.useExpression(ExprSyntax(StringLiteralExprSyntax { builder in
                        builder.useOpenQuote(SyntaxFactory.makeStringQuoteToken())
                        builder.addSegment(Syntax(StringSegmentSyntax { builder in
                            builder.useContent(SyntaxFactory.makeStringSegment(variable.key))
                        }))
                        builder.useCloseQuote(SyntaxFactory.makeStringQuoteToken())
                    }))
                })
                builder.useRightBracket(SyntaxFactory.makeRightSquareBracketToken())
            }))
        }
    }
}

extension MemberDeclListItemSyntax {

    static func buildMappingFunc(
        modelType: ModelType,
        protocolType: ProtocolType,
        isPublic: Bool,
        indentation: Indentation
    ) -> MemberDeclListItemSyntax {

        MemberDeclListItemSyntax { builder in
            builder.useDecl(DeclSyntax(FunctionDeclSyntax { builder in
                let isMutating = modelType == .struct && protocolType == .mappable
                var needSkipLine = true
                if isPublic {
                    builder.addModifier(DeclModifierSyntax { builder in
                        builder.useName(SyntaxFactory.makePublicKeyword(leadingTrivia: .skipALine + .indent(from: indentation), trailingTrivia: .space))
                    })
                    needSkipLine = false
                }
                if isMutating {
                    builder.addModifier(DeclModifierSyntax { builder in
                        builder.useName(
                            SyntaxFactory.makeIdentifier(
                                "mutating",
                                leadingTrivia: needSkipLine ? .skipALine + .indent(from: indentation) : .zero,
                                trailingTrivia: .space
                            )
                        )
                    })
                    needSkipLine = false
                }
                builder.useFuncKeyword(
                    SyntaxFactory.makeFuncKeyword(
                        leadingTrivia: needSkipLine ? .skipALine + .indent(from: indentation) : .zero,
                        trailingTrivia: .space
                    )
                )
                builder.useIdentifier(SyntaxFactory.makeIdentifier("mapping"))
                builder.useSignature(FunctionSignatureSyntax { builder in
                    builder.useInput(ParameterClauseSyntax { builder in
                        builder.useLeftParen(SyntaxFactory.makeLeftParenToken())
                        builder.addParameter(FunctionParameterSyntax { builder in
                            builder.useFirstName(SyntaxFactory.makeIdentifier("map"))
                            builder.useColon(
                                SyntaxFactory.makeColonToken(trailingTrivia: .space)
                            )
                            builder.useType(TypeSyntax(SimpleTypeIdentifierSyntax { builder in
                                builder.useName(SyntaxFactory.makeIdentifier("Map"))
                            }))
                        })
                        builder.useRightParen(
                            SyntaxFactory.makeRightParenToken(trailingTrivia: .space)
                        )
                    })
                })
                builder.useBody(CodeBlockSyntax.buildEmptyBody(indentation: indentation))
            }))
        }
    }

    static func buildInitializer(
        modelType: ModelType,
        protocolType: ProtocolType,
        isPublic: Bool,
        indentation: Indentation
    ) -> MemberDeclListItemSyntax {

        MemberDeclListItemSyntax({ builder in
            builder.useDecl(DeclSyntax(InitializerDeclSyntax({ builder in
                let isRequired = modelType == .class
                var needSkipLine = true
                if isRequired {
                    builder.addModifier(DeclModifierSyntax({ builder in
                        builder.useName(SyntaxFactory.makeIdentifier("required").withLeadingTrivia(
                            .skipALine + .indent(from: indentation)
                        ).withTrailingTrivia(.space))
                    }))
                    needSkipLine = false
                }
                if isPublic {
                    builder.addModifier(DeclModifierSyntax { builder in
                        builder.useName(
                            SyntaxFactory.makePublicKeyword(
                                leadingTrivia: needSkipLine ? .skipALine + .indent(from: indentation) : .zero,
                                trailingTrivia: .space
                            )
                        )
                    })
                    needSkipLine = false
                }
                builder.useInitKeyword(SyntaxFactory.makeInitKeyword(
                    leadingTrivia: needSkipLine ? .skipALine + .indent(from: indentation) : .zero
                ))
                if protocolType == .mappable {
                    builder.useOptionalMark(SyntaxFactory.makePostfixQuestionMarkToken())
                }
                builder.useParameters(ParameterClauseSyntax({ builder in
                    builder.useLeftParen(SyntaxFactory.makeLeftParenToken())
                    builder.addParameter(FunctionParameterSyntax({ builder in
                        builder.useFirstName(SyntaxFactory.makeIdentifier("map"))
                        builder.useColon(SyntaxFactory.makeColonToken(trailingTrivia: .space))
                        builder.useType(TypeSyntax(SimpleTypeIdentifierSyntax({ builder in
                            builder.useName(SyntaxFactory.makeIdentifier("Map"))
                        })))
                    }))
                    builder.useRightParen(SyntaxFactory.makeRightParenToken(trailingTrivia: .space))
                }))
                if protocolType == .immutableMappable {
                    builder.useThrowsOrRethrowsKeyword(SyntaxFactory.makeThrowsKeyword(trailingTrivia: .space))
                }
                builder.useBody(CodeBlockSyntax.buildEmptyBody(indentation: indentation))
            })))
        })
    }
}

extension Trivia {

    static func indent(from indentation: Indentation) -> Trivia {
        indentation.useTabs ?
            .tabs(indentation.level) :
            .spaces(indentation.level * indentation.indentationWidth)
    }

    static var space: Trivia { .spaces(1) }

    static var newline: Trivia { .newlines(1) }

    static var skipALine: Trivia { .newlines(2) }
}

extension CodeBlockSyntax {

    static func buildEmptyBody(indentation: Indentation) -> CodeBlockSyntax {

        CodeBlockSyntax { builder in
            builder.useLeftBrace(SyntaxFactory.makeLeftBraceToken())
            builder.addStatement(CodeBlockItemSyntax({ _ in }))
            builder.useRightBrace(
                SyntaxFactory.makeRightBraceToken(
                    leadingTrivia: .newline + .indent(from: indentation)
                )
            )
        }
    }
}

extension ModifierListSyntax {

    var hasPublic: Bool {
        contains { ["public", "open"].contains($0.name.text) }
    }
}
