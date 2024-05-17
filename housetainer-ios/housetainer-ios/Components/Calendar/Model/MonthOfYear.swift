//
//  MonthOfYear.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/10/24.
//

import Foundation

private let calendar = Calendar.gmt

struct MonthOfYear {
    let _storage: Date
    let components: DateComponents
    
    init(){
        self.init(calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!)
    }
    
    init(_ date: Date){
        _storage = date
        components = calendar.dateComponents([.year, .month], from: date)
    }
    
    var year: Int{
        get{
            components.year ?? 0
        }
        set{
            let date = calendar.date(bySetting: .year, value: newValue, of: _storage) ?? _storage
            self = MonthOfYear(date)
        }
    }
    
    var month: Int{
        get{
            components.month ?? 0
        }
        set{
            let date = calendar.date(bySetting: .month, value: newValue, of: _storage) ?? _storage
            self = MonthOfYear(date)
        }
    }
    
    var date: Date{
        _storage
    }
}

extension MonthOfYear: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool{
        lhs._storage == rhs._storage
    }
}

extension MonthOfYear: Comparable {
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

extension MonthOfYear: Strideable{
    typealias Stride = Int
    
    func distance(to other: MonthOfYear) -> Stride {
        calendar.dateComponents([.month], from: self._storage, to: other._storage).day ?? 0
    }
    
    func advanced(by n: Stride) -> MonthOfYear {
        let other = calendar.date(byAdding: .month, value: n, to: self._storage)
        precondition(other != nil, "존재하지 않는 날짜입니다.")
        return MonthOfYear(other!)
    }
}
