//
//  HouseWithNickname.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/7/24.
//

import Foundation

struct HouseWithNickname {
    let response: HouseWithNicknameRes
    
    var id: String {
        response.id
    }
    var nickname: String {
        response.member.nickname
    }
    var category: String {
        response.category
    }
    var imageUrl: URL? {
        guard let imageURLs = response.imageURLs, !imageURLs.isEmpty else { return nil }
        return URL(string: "\(Url.imageBase(Table.houses.rawValue))/\(imageURLs[response.coverImageIndex])")
    }
}
