//
//  DayOfMonth.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/9/24.
//

import Foundation

private let calendar = Calendar.gmt

struct DayOfMonth {
    let _storage: Date
    let components: DateComponents
    
    init(){
        self.init(calendar.date(from: calendar.dateComponents([.month, .day], from: Date()))!)
    }
    
    init(_ date: Date){
        _storage = date
        components = calendar.dateComponents([.day, .month, .weekday], from: date)
    }
    
    var day: Int{
        components.day ?? 0
    }
    
    var week: Int{
        components.weekday ?? 0
    }
    
    var month: Int{
        components.month ?? 0
    }
    
    var date: Date{
        _storage
    }
}

extension DayOfMonth: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool{
        lhs._storage == rhs._storage
    }
}

extension DayOfMonth: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool{
        lhs._storage < rhs._storage
    }
    
    static func <= (lhs: Self, rhs: Self) -> Bool{
        lhs._storage <= rhs._storage
    }
    
    static func >= (lhs: Self, rhs: Self) -> Bool{
        lhs._storage >= rhs._storage
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool{
        lhs._storage > rhs._storage
    }
}

extension DayOfMonth: Strideable{
    typealias Stride = Int
    
    func distance(to other: DayOfMonth) -> Stride {
        calendar.dateComponents([.day], from: self._storage, to: other._storage).day ?? 0
    }
    
    func advanced(by n: Stride) -> DayOfMonth {
        let other = calendar.date(byAdding: .day, value: n, to: self._storage)
        precondition(other != nil, "존재하지 않는 날짜입니다.")
        return DayOfMonth(other!)
    }
}
