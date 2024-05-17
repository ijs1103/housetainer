//
//  RegexHelper.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/23/24.
//

import Foundation

enum RegexHelper {
    static func matchesRegex(_ string: String, regex: Regex) -> Bool {
        let regex = try? NSRegularExpression(pattern: regex.rawValue)
        let range = NSRange(location: 0, length: string.utf16.count)
        return regex?.firstMatch(in: string, options: [], range: range) != nil
    }
}
