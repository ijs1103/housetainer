//
//  CommentCellData.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/26/24.
//

import Foundation

struct CommentCellData {
    let id: String
    let writerId: String
    let nickname: String
    let createdAt: String
    let content: String
    let profileUrl: URL?
    let isHousetainer: Bool
}
