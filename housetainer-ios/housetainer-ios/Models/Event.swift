//
//  Event.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/17.
//
import Foundation

struct Event: Hashable {
    let response: EventDTO
    
    var id: String {
        response.id
    }
    var createdAt: String {
        response.createdAt.parsedDate()
    }
    var title: String {
        response.title
    }
    var scheduleType: String {
        response.scheduleType
    }
    var memberId: String {
        response.ownerId
    }
    var date: String {
        response.date.parsedDate()
    }
    var isPast: Bool {
        Date().isPast(response.date)
    }
    var detail: String {
        response.detail
    }
    var relatedLink: String {
        response.title
    }
    var canDisplay: Bool {
        response.displayType == "Y"
    }
    var imageUrl: URL? {
        if let imageUrl = response.imageUrls.first {
            return URL(string: imageUrl)
        } else {
            return nil
        }
//        return URL(string: "\(Url.imageBase(Table.events.rawValue))/\(response.fileName)")!
    }
}
