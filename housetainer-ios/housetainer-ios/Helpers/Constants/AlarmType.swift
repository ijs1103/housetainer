//
//  AlarmType.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/16/24.
//

enum AlarmType: String {
    case bookmark = "event_bookmarks.insert"
    case eventComments = "event_comments.insert"
    case houseComments = "house_comments.insert"
    case bookmarkEventComments = "event_bookmarks.event_comments.insert"
    
    var iconName: String {
        switch self {
        case .bookmark:
            return "icon_saved_alarm"
        case .eventComments:
            return "icon_comment_alarm"
        case .houseComments:
            return "icon_homeletter_alarm"
        case .bookmarkEventComments:
            return "icon_comment_alarm"
        }
    }
    
    var text: String {
        switch self {
        case .bookmark:
            return " 님이 회원님의 게시글을 저장했어요."
        case .eventComments:
            return " 님이 회원님이 등록하신 일정에 댓글을 남겼어요."
        case .houseComments:
            return " 님이 회원님에게 홈레터를 남겼어요."
        case .bookmarkEventComments:
            return " 님이 회원님이 저장하신 일정에 댓글을 남겼어요."
        }
    }
}
