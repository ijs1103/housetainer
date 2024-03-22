//
//  SupabaseClient+Default.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/29/24.
//

import Foundation
import Supabase

private enum SupabaseConfiguration{
    static let supabaseURL = URL(string: Configuration.SupabaseUrl)!
    static let supabaseKey: String = Configuration.SupabaseApiKey
}

extension SupabaseClient{
    static let shared = {
        let client = SupabaseClient(supabaseURL: Env.supabaseURL, supabaseKey: Env.supabaseKey)
        return client
    }()
}
