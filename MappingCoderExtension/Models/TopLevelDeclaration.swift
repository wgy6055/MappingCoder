//
//  TopLevelDeclaration.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/1.
//

import Foundation

protocol TopLevelDeclaration {

    var name: String { get }
    var inheritance: [String] { get }
    var variables: [Variable] { get }
    var protocolType: ProtocolType? { get }
    var isPublic: Bool { get }
}
