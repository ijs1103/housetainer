//
//  Report.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/4/24.
//

import Foundation

struct Report: Codable {
    let id: String
    let createdAt: Date
    let title: String
    let category: String
    let content: String
    let answeredAt: Date?
    let answer: String?
    let reporteeId: String?
    let reporterId: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, category, content, answer
        case createdAt = "created_at"
        case answeredAt = "answered_at"
        case reporteeId = "reportee_id"
        case reporterId = "reporter_id"
    }
}
