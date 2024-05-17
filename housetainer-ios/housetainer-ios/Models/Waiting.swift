//
//  Waiting.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/30/24.
//

import Foundation

struct Waiting: Codable {
    let email: String?
    let snsUrl: String?
    let instagramId: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case email
        case createdAt = "created_at"
        case snsUrl = "sns_url"
        case instagramId = "instagram_id"
    }
}
