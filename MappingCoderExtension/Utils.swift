//
//  Utils.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/22.
//

import Foundation
import XcodeKit

enum ProtocolType: String {

    case mappable = "Mappable"
    case immutableMappable = "ImmuatableMappable"
}

extension ProtocolType: CustomStringConvertible {

    var description: String { rawValue }
}

enum ModelType: String {

    case `class`
    case `struct`
}

func json(from buffer: XCSourceTextBuffer) -> [String : Any]? {

    let selections = buffer.selections
    guard let lines = buffer.lines as? [String] else {
        return nil
    }
    let jsonString = selections.reduce("") { string, selection in
        guard let range = selection as? XCSourceTextRange,
              range.start.line <= range.end.line else {
            return string
        }
        func sourceCode(from: XCSourceTextPosition, to: XCSourceTextPosition) -> String {
            let startLine = lines[from.line]
            if from.line == to.line {
                return startLine.substring(from: from.column, to: to.column)
            }
            var sourceCode = ""
            let targetLines = Array(lines[from.line...to.line])
            for i in (0..<targetLines.count) {
                let line = targetLines[i]
                if i == 0 {
                    sourceCode += line.substring(from: from.column)
                } else if i == targetLines.count - 1 {
                    sourceCode += line.substring(to: to.column)
                } else {
                    sourceCode += line
                }
            }
            return sourceCode
        }
        return string + sourceCode(from: range.start, to: range.end)
    }

    return jsonString.trimmingCharacters(in: .whitespacesAndNewlines).toJSONObject
}

func commentSelectios(in buffer: XCSourceTextBuffer) {

    let selections = buffer.selections
    selections.forEach { selection in
        guard let range = selection as? XCSourceTextRange else {
            return
        }
        for i in (range.start.line...range.end.line) {
            guard var line = buffer.lines[i] as? String else {
                return
            }
            line = "//" + line
            buffer.lines.replaceObject(at: i, with: line)
        }
    }
}

func convert(
    json: [String : Any],
    to modelType: ModelType,
    in buffer: XCSourceTextBuffer,
    conformTo protocolType: ProtocolType
) throws {

    let fileIndent = Indentation(
        useTabs: buffer.usesTabsForIndentation,
        indentationWidth: buffer.indentationWidth
    )
    let classIndent = fileIndent.indent()
    let funcIndent = classIndent.indent()

    var lines: [String] = [""]
    lines.append("\(modelType) <#name#" + ">: \(protocolType) {")
    lines.append("")

    lines += json.map {
        PropertyDeclaration(
            name: $0, // TODO: camelCase
            jsonValue: $1,
            keyword: protocolType == .mappable ? .var : .let,
            isOptional: false // TODO: support config
        )
    }.sorted { $0.name < $1.name }.map { "\(classIndent)\($0)" }
    lines.append("")

    if protocolType == .mappable {
        lines.append("\(classIndent)\(modelType == .class ? "required " : "")init?(map: Map) {}")
    } else {
        lines.append("\(classIndent)\(modelType == .class ? "required " : "")init(map: Map) throws {")
        lines += json.keys.map {
            TryMapValueExpression(
                name: $0, // TODO: camelCase
                key: $0,
                isOptional: false // TODO: support config
            )
        }.sorted { $0.name < $1.name }.map { "\(funcIndent)\($0)" }
        lines.append("\(classIndent)}")
    }
    lines.append("")

    lines.append("\(classIndent)func mapping(map: Map) {")
    lines += json.keys.map {
        MappingExpression(name: $0, key: $0, protocolType: protocolType)
    }.sorted { $0.name < $1.name }.map { "\(funcIndent)\($0)" }
    lines.append("\(classIndent)}")

    lines.append("}")

    guard let selectionTrail = buffer.selections.lastObject as? XCSourceTextRange else {
        throw NSError(domain: domain, code: -1, userInfo: nil)
    }
    let codeStartLine = selectionTrail.end.line + 1
    lines.reversed().forEach {
        buffer.lines.insert($0, at: codeStartLine)
    }
}
