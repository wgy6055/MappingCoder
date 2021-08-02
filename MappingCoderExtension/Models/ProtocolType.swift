//
//  ProtocolType.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/8/2.
//

import Foundation

enum ProtocolType: String {

    case mappable = "Mappable"
    case immutableMappable = "ImmutableMappable"
}

extension ProtocolType: CustomStringConvertible {

    var description: String { rawValue }
}
