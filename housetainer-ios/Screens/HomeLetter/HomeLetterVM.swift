//
//  HomeLetterVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/24/24.
//

import Foundation
import Combine

final class HomeLetterVM {
    private let houseId: String
    let comments = CurrentValueSubject<[CommentCellData]?, Never>(nil)
    let isCommentRegistered = CurrentValueSubject<Bool?, Never>(nil)
    let isCommentEmpty = CurrentValueSubject<Bool?, Never>(nil)

    init(houseId: String) {
        self.houseId = houseId
    }
}

extension HomeLetterVM {
    func fetchComments() async {
        guard let response = await NetworkService.shared.fetchHouseComments(houseId: houseId) else { return }
        let parsed = response.map { HouseCommentWithMember(response: $0) }
        let data = parsed.map { CommentCellData(nickname: $0.nickname, createdAt: $0.createdAt, content: $0.content, profileUrl: $0.profileUrl, isHousetainer: $0.isHousetainer) }
        comments.send(data)
    }
    
    func registerComment(text: String) async {
        guard let writerId = await NetworkService.shared.userInfo()?.id.uuidString else { return isCommentRegistered.send(false) }
        let comment = HouseComment(id: UUID().uuidString, houseId: houseId, content: text, createdAt: Date(), updatedAt: Date(), parentCommentId: nil, writerId: writerId)
        do {
            try await NetworkService.shared.insertHouseComments(comment)
            isCommentRegistered.send(true)
        } catch {
            print("insertHouseComments - supabase error")
            isCommentRegistered.send(false)
        }
    }
}
