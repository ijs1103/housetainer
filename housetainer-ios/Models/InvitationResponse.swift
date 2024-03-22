//
//  InvitationResponse.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/17/24.
//

import Foundation

struct InvitationResponse: Codable {
    let createdAt: Date
    let code: String
    let inviterId: String    
    let inviteeEmail: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case code, status
        case createdAt = "created_at"
        case inviterId = "inviter_id"
        case inviteeEmail = "invitee_email"
    }
}
