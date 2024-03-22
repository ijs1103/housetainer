//
//  EventToUpdate.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/20/24.
//

import Foundation

struct EventToUpdate: Encodable {
    let id: String
    let title: String
    let scheduleType: String
    let date: Date
    let detail: String
    let relatedLink: String
    let fileName: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, date, detail
        case scheduleType = "schedule_type"
        case relatedLink = "related_link"
        case fileName = "file_name"
    }
}
