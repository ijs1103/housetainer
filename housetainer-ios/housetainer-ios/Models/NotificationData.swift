//
//  NotificationData.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/11/24.
//

import Foundation

struct NotificationData {
    let response: NotificationDTO
    
    var read: Bool {
        response.read
    }
    
    var houseId: String? {
        response.houseId
    }
    
    var houseCommentId: String? {
        response.houseCommentId
    }
    
    var eventId: String? {
        response.eventId
    }
    
    var eventCommentId: String? {
        response.eventCommentId
    }
    
    var nickname: String {
        response.actorUsername
    }
    
    var alarmType: AlarmType {
        if let alarmType = AlarmType(rawValue: response.type) {
            return alarmType
        } else {
            print("Invalid alarm type")
            return AlarmType.bookmark
        }
    }
}
