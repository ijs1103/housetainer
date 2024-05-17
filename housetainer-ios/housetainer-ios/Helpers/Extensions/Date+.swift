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
    
    func isDateMoreThanAWeek() -> Bool {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        return self < (oneWeekAgo ?? Date())
    }
    
    func toISO8601String() -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter.string(from: self)
    }
}
