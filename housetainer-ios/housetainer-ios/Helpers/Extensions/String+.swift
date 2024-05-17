//
//  String+.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/17/24.
//

import Foundation

extension String {
    func stringWithCharacterLimit(max characterLimit: Int) -> String {
        if self.count > characterLimit {
            let index = self.index(self.startIndex, offsetBy: characterLimit)
            return String(self[..<index])
        } else {
            return self
        }
    }
    func toDate(with format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.date(from: self)
    }
    func isEmptyOrWhitespace() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
