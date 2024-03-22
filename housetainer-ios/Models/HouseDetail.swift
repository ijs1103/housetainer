//
//  HouseDetail.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/28/24.
//

import Foundation

struct HouseDetail {
    let response: HouseDetailResponse
    
    var id: String {
        response.id ?? "id 없음"
    }
    var createdAt: String {
        response.createdAt?.parsedDate() ?? "createdAt 없음"
    }
    var updatedAt: String {
        response.updatedAt?.parsedDate() ?? "updatedAt 없음"
    }
    var ownerId: String {
        response.ownerId ?? "createdAt 없음"
    }
    var name: String {
        response.name ?? "createdAt 없음"
    }
    var category: HouseCategory? {
        HouseCategory(rawValue: response.category)
    }
    var title: String {
        response.title ?? "제목 없음"
    }
    var content: String {
        response.content ?? "내용 없음"
    }
    var imageURLs: [String] {
        response.imageURLs ?? []
    }
    var coverImageUrl: URL? {
        if let imageURLs = response.imageURLs, !imageURLs.isEmpty {
            return URL(string: "\(Url.imageBase(Table.houses.rawValue))/\(imageURLs[response.coverImageIndex])")

        }
        return nil
    }
    var domestic: Bool {
        response.domestic ?? false
    }
    var location: String {
        response.location ?? "location 없음"
    }
    var detailedLocation: String {
        response.detailedLocation ?? "detailedLocation 없음"
    }
    var displayType: String {
        response.displayType ?? "displayType 없음"
    }
    var isHousetainer: Bool {
        response.owner.memberType == "H"
    }
    var nickname: String {
        response.owner.nickname
    }
    var profileUrl: URL? {
        if let profileUrl = response.owner.profileUrl {
            return URL(string: profileUrl)
        } else {
            return nil
        }
    }
}
