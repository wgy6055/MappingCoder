//
//  Settings.swift
//  MappingCoder
//
//  Created by Wang Guanyu on 2021/8/2.
//

import Foundation

struct Settings {

    private struct Key {
        static let modelType = "modelType"
        static let optional = "optional"
    }

    private static let teamIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "TeamIdentifierPrefix") as? String

    private static let sharedUserDefaults = UserDefaults(suiteName: "\(teamIdentifierPrefix ?? "")com.wgy.MappingCoder")

    private let userDefaults = sharedUserDefaults

    var modelType: ModelType {
        get {
            guard let rawValue = userDefaults?.object(forKey: Key.modelType) as? String,
                  let modelType = ModelType(rawValue: rawValue) else {
                return .struct
            }
            return modelType
        }
        set {
            userDefaults?.setValue(newValue.rawValue, forKey: Key.modelType)
            userDefaults?.synchronize()
        }
    }

    var optional: Bool {
        get {
            guard let optional = userDefaults?.object(forKey: Key.optional) as? Bool else {
                return false
            }
            return optional
        }
        set {
            userDefaults?.setValue(newValue, forKey: Key.optional)
            userDefaults?.synchronize()
        }
    }
}
