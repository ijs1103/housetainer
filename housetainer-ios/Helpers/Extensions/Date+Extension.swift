//
//  Date+Extension.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/17/24.
//

import Foundation

extension Date{
    func format(with format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}

extension Date{
    init?(datetime: String){
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: datetime) else{ return nil }
        self = date
    }
  
    init?(date: String){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        guard let date = formatter.date(from: date) else{ return nil }
        self = date
    }
    
    func datetime() -> String{
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    func date() -> String{
        format(with: "yyyy-MM-dd")
    }
}
