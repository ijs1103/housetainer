//
//  URL+.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/20/24.
//

import Foundation

extension URL {
    func urlToFileName() -> String {
        self.pathComponents.suffix(2).joined(separator: "/")
    }
}

