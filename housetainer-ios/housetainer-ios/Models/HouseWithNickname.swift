//
//  HouseWithNickname.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/7/24.
//

import Foundation

struct HouseWithNickname: Hashable {
    let response: HouseWithNicknameRes
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HouseWithNickname, rhs: HouseWithNickname) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String {
        response.id
    }
    var nickname: String {
        response.member.username
    }
    var category: String {
        response.category
    }
    var imageUrl: URL? {
        guard let imageURLs = response.imageURLs, !imageURLs.isEmpty else { return nil }
        return URL(string: imageURLs[response.coverImageIndex])
    }
}
