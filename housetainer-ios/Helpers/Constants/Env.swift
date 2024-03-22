//
//  Env.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/14.
//

import Foundation

struct Env {
    private init () {}
    static let supabaseURL = URL(string: "https://tueyrdhxvqocbcatpxdn.supabase.co")!
    static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1ZXlyZGh4dnFvY2JjYXRweGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODExMDgyOTksImV4cCI6MTk5NjY4NDI5OX0.6g2G4JltqqFJQUp7eGHloRowrnKA6SyodY_1P-3DfwY"
    static let kakaoAppKey = "bef0a870af7f6de6530b4db494783aa8"
}
