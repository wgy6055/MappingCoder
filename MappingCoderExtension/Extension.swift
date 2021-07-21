//
//  Extension.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/19.
//

import Foundation

extension String {

    func substring(from idx: Int) -> String {
        guard idx < count else {
            return ""
        }
        let start = index(startIndex, offsetBy: idx)
        return String(self[start...])
    }

    func substring(to idx: Int) -> String {
        guard idx < count else {
            return self
        }
        let end = index(startIndex, offsetBy: idx)
        return String(self[...end])
    }

    func substring(from: Int, to: Int) -> String {
        guard from <= to else {
            return ""
        }
        let safeFrom = max(from, 0)
        let safeTo = min(to, count - 1)
        let start = index(startIndex, offsetBy: safeFrom)
        let end = index(startIndex, offsetBy: safeTo)
        return String(self[start...end])
    }

    var toJSONObject: [String : Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String : Any]
    }
}
