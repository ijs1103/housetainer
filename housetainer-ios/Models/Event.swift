//
//  Event.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/17.
//
import Foundation

struct Event: Hashable {
    let response: EventDto
    
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
        response.title
    }
    var memberId: String {
        response.memberId
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
    var imageUrl: URL {
        return URL(string: "\(Url.imageBase(Table.events.rawValue))/\(response.fileName)")!
    }
}
