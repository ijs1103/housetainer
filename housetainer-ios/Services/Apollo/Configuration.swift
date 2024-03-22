//
//  Configuration.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/29/24.
//

import Foundation

@dynamicMemberLookup
enum Configuration{
    static subscript<T>(dynamicMember key: String) -> T {
        let value = Bundle.main.infoDictionary?[key]
        precondition(value != nil, "no configuration found in Info.plist. expected key: \(key)")
        return value as! T
    }
}


