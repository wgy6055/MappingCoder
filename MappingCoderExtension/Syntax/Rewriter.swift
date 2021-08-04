//
//  Rewriter.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/1.
//

import Foundation
import SwiftSyntax

class Rewriter: SyntaxRewriter {

    private let topLevel: TopLevelDeclaration
    private var name: String { topLevel.name }
    private var inheritance: [String] { topLevel.inheritance }
    private var protocolType: ProtocolType? { topLevel.protocolType }
    private var variables: [Variable] { topLevel.variables }
    private var `operator`: String { protocolType == .mappable ? "<-" : ">>>" }
    private var isPublic: Bool { topLevel.isPublic }

    private var useTabs: Bool
    private var indentationWidth: Int
    private let memberIndent: Indentation
    private var exprIndent: Indentation { memberIndent.indent() }

    init(topLevel: TopLevelDeclaration, useTabs: Bool, indentationWidth: Int) {
        self.topLevel = topLevel
        self.useTabs = useTabs
        self.indentationWidth = indentationWidth
        self.memberIndent = Indentation(
            useTabs: useTabs,
            indentationWidth: indentationWidth,
            level: 1
        )
    }

    override func visit(_ node: MemberDeclListSyntax) -> Syntax {

        guard let nearestTopLevel = node.nearestTopLevelDecl else {
            return Syntax(node)
        }

        let nearestTopLevelName: String?
        if let nearestClass = nearestTopLevel as? ClassDeclSyntax {
            nearestTopLevelName = nearestClass.identifier.text
        } else if let nearestStruct = nearestTopLevel as? StructDeclSyntax {
            nearestTopLevelName = nearestStruct.identifier.text
        } else {
            nearestTopLevelName = nil
        }

        let modelType: ModelType?
        if topLevel is Class {
            modelType = .class
        } else if topLevel is Structure {
            modelType = .struct
        } else {
            modelType = nil
        }

        guard let nearestTopLevelName = nearestTopLevelName,
              nearestTopLevelName == name,
              let modelType = modelType,
              let protocolType = protocolType else {
            return Syntax(node)
        }

        guard let initNode = rewriteInitializer(
                list: node,
                modelType: modelType,
                protocolType: protocolType
        ) else {
            return Syntax(node)
        }
        guard let mappingNode = rewriteMappingFunc(
                list: initNode,
                modelType: modelType,
                protocolType: protocolType
        ) else {
            return Syntax(initNode)
        }
        return Syntax(mappingNode)
    }

    // MARK: - Private Method

    private func rewriteInitializer(
        list: MemberDeclListSyntax,
        modelType: ModelType,
        protocolType: ProtocolType
    ) -> MemberDeclListSyntax? {

        let initItemIndex = list.firstIndex {
            guard let initializer = $0.decl.asProtocol(DeclSyntaxProtocol.self)
                    as? InitializerDeclSyntax,
                  initializer.isInitMap(modelType: modelType, protocolType: protocolType),
                  (isPublic ? (initializer.modifiers?.hasPublic ?? false) : true) else {
                return false
            }
            return true
        }
        let initItem: MemberDeclListItemSyntax
        if let initItemIndex = initItemIndex {
            initItem = list[initItemIndex]
        } else {
            initItem = MemberDeclListItemSyntax.buildInitializer(
                modelType: modelType,
                protocolType: protocolType,
                isPublic: isPublic,
                indentation: memberIndent
            )
        }

        guard let initializer = initItem.decl.asProtocol(DeclSyntaxProtocol.self)
                as? InitializerDeclSyntax else {
            return nil
        }
        var body: CodeBlockSyntax
        if let initBody = initializer.body {
            body = initBody
        } else {
            body = CodeBlockSyntax.buildEmptyBody(indentation: memberIndent)
        }
        var statements = body.statements

        if protocolType == .immutableMappable {
            let existVariableNames: [String] = body.statements.compactMap {
                guard let expression = $0.item.asProtocol(ExprSyntaxProtocol.self)
                        as? SequenceExprSyntax else {
                    return nil
                }
                guard let firstExpr = expression.elements.first?.asProtocol(ExprSyntaxProtocol.self)
                        as? IdentifierExprSyntax else {
                    return nil
                }
                return firstExpr.identifier.text
            }
            let variables = variables
                .filter { !existVariableNames.contains($0.name) }
                .filter { !$0.isConstant }
            let newStatements = variables.map { variable in
                CodeBlockItemSyntax { builder in
                    builder.useItem(Syntax(
                        SequenceExprSyntax.buildInitExpr(variable: variable, indentation: exprIndent)
                    ))
                }
            }
            newStatements.forEach { statements = statements.appending($0) }
        }

        let newItem = initItem.withDecl(
            DeclSyntax(initializer.withBody(body.withStatements(statements)))
        )
        let newList: MemberDeclListSyntax
        if let initItemIndex = initItemIndex {
            newList = list.replacing(
                childAt: list.index(of: initItemIndex),
                with: newItem
            )
        } else {
            newList = list.appending(newItem)
        }
        return newList
    }

    private func rewriteMappingFunc(
        list: MemberDeclListSyntax,
        modelType: ModelType,
        protocolType: ProtocolType
    ) -> MemberDeclListSyntax? {

        let mappingItemIndex = list.firstIndex {
            guard let function = $0.decl.asProtocol(DeclSyntaxProtocol.self)
                    as? FunctionDeclSyntax,
                  function.isMapping,
                  (isPublic ? (function.modifiers?.hasPublic ?? false) : true ) else {
                return false
            }
            return true
        }

        let mappingItem: MemberDeclListItemSyntax
        if let mappingItemIndex = mappingItemIndex {
            mappingItem = list[mappingItemIndex]
        } else {
            mappingItem = MemberDeclListItemSyntax.buildMappingFunc(
                modelType: modelType,
                protocolType: protocolType,
                isPublic: isPublic,
                indentation: memberIndent
            )
        }

        guard let mappingFunc = mappingItem.decl.asProtocol(DeclSyntaxProtocol.self)
                as? FunctionDeclSyntax else {
            return nil
        }
        var body: CodeBlockSyntax
        if let funcBody = mappingFunc.body {
            body = funcBody
        } else {
            body = CodeBlockSyntax.buildEmptyBody(indentation: memberIndent)
        }
        let existVariableNames: [String] = body.statements.compactMap {
            guard let expression = $0.item.asProtocol(ExprSyntaxProtocol.self)
                    as? SequenceExprSyntax else {
                return nil
            }
            guard let firstExpr = expression.elements.first?.asProtocol(ExprSyntaxProtocol.self)
                    as? IdentifierExprSyntax else {
                return nil
            }
            return firstExpr.identifier.text
        }
        let variables = variables.filter { !existVariableNames.contains($0.name) }
        var statements = body.statements
        let newStatements = variables.map { variable in
            CodeBlockItemSyntax { builder in
                builder.useItem(Syntax(
                    SequenceExprSyntax.buildMappingExpr(
                        variable: variable,
                        operator: `operator`,
                        indentation: exprIndent
                    )
                ))
            }
        }
        newStatements.forEach { statements = statements.appending($0) }
        let newItem = mappingItem.withDecl(
            DeclSyntax(mappingFunc.withBody(body.withStatements(statements)))
        )
        let newList: MemberDeclListSyntax
        if let mappingItemIndex = mappingItemIndex {
            newList = list.replacing(
                childAt: list.index(of: mappingItemIndex),
                with: newItem
            )
        } else {
            newList = list.appending(newItem)
        }
        return newList
    }
}
