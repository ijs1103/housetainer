//
//  HouseOwner.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/23/24.
//

import Foundation

struct HouseOwner {
    let response: HouseOwnerResponse
    
    var id: String {
        response.id
    }
    var isHousetainer: Bool {
        response.memberType == "H"
    }
    var nickname: String {
        response.username
    }
    var profileUrl: URL? {
        if let profileUrl = response.profileUrl {
            return URL(string: profileUrl)
        } else {
            return nil
        }
    }
    
}
