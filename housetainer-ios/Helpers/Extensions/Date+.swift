//
//  Date+.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/23.
//

import Foundation

extension Date {
    func parsedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: self)
    }
    
    func isPast(_ date: Date) -> Bool {
        let result: ComparisonResult = self.compare(date)
        switch result {
        case .orderedAscending, .orderedSame:
            return false
        case .orderedDescending:
            return true
        }
    }
}
