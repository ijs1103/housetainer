//
//  ToastMessage.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/31/24.
//

struct ToastMessage {
    private init() {}
    static let getNewsSuccess = "소식받기에 등록되었습니다."
    static let getNewsDuplicate = "이미 소식받기에 등록되어 있습니다."
    static let notExistingInvitation = "올바르지 않은 초대코드 혹은 이메일입니다."
    static let commentRegisteredSuccess = "댓글이 등록되었습니다."
    static let commentRegisteredFailed = "댓글 등록에 실패하였습니다."
    static let eventDeletionSuccess = "소셜캘린더를 삭제하였습니다."
    static let eventDeletionFailed = "소셜캘린더 삭제를 실패하였습니다."
    static let addingBookmarkSuccess = "즐겨찾기에 추가되었습니다."
    static let deletingBookmarkSuccess = "즐겨찾기에서 삭제되었습니다."
    static let addingBookmarkFailed = "내가 만든 일정은 즐겨찾기 할 수 없습니다."
    static let emptyComment = "댓글을 입력하지 않았습니다."
    static let emptyHomeLetter = "홈 레터를 입력하지 않았습니다."
    static let reportingFailed = "신고하기를 실패하였습니다."
    static let deletingCommentSuccess = "댓글을 삭제하였습니다."
    static let deletingCommentFailed = "댓글 삭제를 실패하였습니다."
    static func specialGuestWelcome(nickname: String) -> String {
        "하우스테이너 운영자 초대로 오신 \(nickname)님 환영합니다."
    }
    static let eventInsertingSuccess = "일정을 생성하였습니다."
    static let eventInsertingFailed = "일정 생성에 실패하였습니다."
    static let eventUpdatingSuccess = "소셜캘린더가 수정되었습니다"
    static let eventUpdatingFailed = "소셜캘린더 수정에 실패하였습니다"
    static let userBlockingSuccess = "유저를 차단하였습니다"
    static let userBlockingFailed = "유저 차단에 실패하였습니다"
}
