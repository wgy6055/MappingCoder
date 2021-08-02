//
//  ExpressibleBySyntax.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/1.
//

import Foundation
import SwiftSyntax

/// A type that can be initialized with a Swift syntax node.
public protocol ExpressibleBySyntax {
    associatedtype Syntax: SyntaxProtocol

    /// Creates an instance initialized with the given syntax node.
    init?(_ node: Syntax)
}
