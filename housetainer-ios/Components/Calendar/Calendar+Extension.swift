//
//  Calendar+Extension.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/10/24.
//

import Foundation

extension Calendar{
    static let gmt = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale.init(identifier: "ko_kr")
        return calendar
    }()
}
