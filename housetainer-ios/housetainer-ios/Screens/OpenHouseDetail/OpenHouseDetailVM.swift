//
//  OpenHouseDetailVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/23/24.
//

import Foundation
import Combine

final class OpenHouseDetailVM {
    private let houseId: String
    let house = CurrentValueSubject<HouseDetail?, Never>(nil)
    let houseCommentsCount = CurrentValueSubject<Int, Never>(0)
    let isUserBlocked = CurrentValueSubject<Bool?, Never>(nil)
    init(houseId: String) {
        self.houseId = houseId
    }
}

extension OpenHouseDetailVM {
    func fetchHouse() async {
        guard let response = await NetworkService.shared.fetchHouseDetail(id: houseId) else { return }
        house.send(HouseDetail(response: response))
    }

    func fetchHouseCommentsCount() async {
        let count = await NetworkService.shared.fetchHouseCommentsCount(houseId: houseId)
        houseCommentsCount.send(count)
    }
    
    func getHouseId() -> String {
        houseId
    }
    
    func blockUser(id: String) async {
        guard let reporterId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        let blockedMember = BlockedMemberDTO(reporterId: reporterId, blockedMemberId: id)
        let isUserBlocked = await NetworkService.shared.insertBlockedMember(blockedMember)
        self.isUserBlocked.send(isUserBlocked)
    }
}
