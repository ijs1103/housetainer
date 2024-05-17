//
//  QsConfig.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/18/24.
//

import Foundation

struct QsConfig: Codable {
  let supabaseUrl: String
  let supabaseAnonKey: String
  let needSignupInvitation: Bool
  
  enum CodingKeys: String, CodingKey {
        case supabaseUrl = "supabase_url"
        case supabaseAnonKey = "supabase_anon_key"
        case needSignupInvitation = "need_signup_invitation"
  }
}
