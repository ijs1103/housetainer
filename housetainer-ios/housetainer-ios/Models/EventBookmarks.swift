//
//  EventBookmarkedOwners.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/29/24.
//

import Foundation

struct EventBookmarks: Decodable {
    let id: String
    let bookmarks: [Bookmark]

    enum CodingKeys: String, CodingKey {
        case id, bookmarks
    }
}

struct Bookmark: Decodable {
    let ownerId: String
    let eventId: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case ownerId = "owner_id"
        case eventId = "event_id"
        case createdAt = "created_at"
    }
}


