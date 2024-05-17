//
//  Env.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/14.
//

import Foundation

struct Env {
    private init () {}
    static let supabaseURL = URL(string: "https://bkcycwzxsnkhdtwxpgjk.supabase.co")!
    static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrY3ljd3p4c25raGR0d3hwZ2prIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTMxNTA2ODcsImV4cCI6MjAyODcyNjY4N30.wECGfKlj_aeyMwBqWH8dnLaJm2qYd6YbSy_FXXPGjgo"
    static let kakaoAppKey = "40f7975ac73302181c9c6eb6368dc478"
}
