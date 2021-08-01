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
    case immutableMappable = "ImmutableMappable"
}

extension ProtocolType: CustomStringConvertible {

    var description: String { rawValue }
}

enum ModelType: String {

    case `class`
    case `struct`
}

func json(from buffer: XCSourceTextBuffer) -> [String : Any]? {
    buffer.joinedSelectedString.trimmingCharacters(in: .whitespacesAndNewlines).toJSONObject
}

func convert(
    json: [String : Any],
    to modelType: ModelType,
    in buffer: XCSourceTextBuffer,
    at startLine: Int,
    conformTo protocolType: ProtocolType
) {

    let fileIndent = Indentation(
        useTabs: buffer.usesTabsForIndentation,
        indentationWidth: buffer.indentationWidth
    )
    let classIndent = fileIndent.indent()
    let funcIndent = classIndent.indent()

    var lines: [String] = [""]
    lines.append("\(modelType) " + "name".asPlaceholder + ": \(protocolType) {")
    lines.append("")

    let properties = json.map {
        PropertyDeclaration(
            name: $0.camelCase,
            jsonValue: $1,
            keyword: protocolType == .mappable ? .var : .let,
            isOptional: false // TODO: support config
        )
    }.sorted { $0.name < $1.name }
    lines += properties.map { "\(classIndent)\($0)" }
    lines.append("")

    if protocolType == .mappable {
        lines.append("\(classIndent)\(modelType == .class ? "required " : "")init?(map: Map) {}")
    } else {
        lines.append("\(classIndent)\(modelType == .class ? "required " : "")init(map: Map) throws {")
        lines += json.keys.map {
            TryMapValueExpression(
                name: $0.camelCase,
                key: $0,
                isOptional: false // TODO: support config
            )
        }.sorted { $0.name < $1.name }.map { "\(funcIndent)\($0)" }
        lines.append("\(classIndent)}")
    }
    lines.append("")

    lines.append("\(classIndent)func mapping(map: Map) {")
    lines += json.keys.map {
        MappingExpression(name: $0.camelCase, key: $0, protocolType: protocolType)
    }.sorted { $0.name < $1.name }.map { "\(funcIndent)\($0)" }
    lines.append("\(classIndent)}")

    lines.append("}")

    lines.reversed().forEach {
        buffer.lines.insert($0, at: startLine)
    }

    // convert nested JSONs
    let nestedJSONs = properties.compactMap { $0.nestedJSONValue }
    nestedJSONs.forEach {
        convert(
            json: $0,
            to: modelType,
            in: buffer,
            at: startLine + lines.count,
            conformTo: protocolType
        )
    }
}
