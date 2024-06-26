//
//  Url.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/21.
//

struct Url {
    private init () {}
    static func imageBase(_ tableName: String) -> String {
        "\(RemoteConfigManager.shared.data.supabaseUrl.absoluteString)/storage/v1/object/public/\(tableName)"
    }
    static let interStyleMagazine = "https://post.naver.com/culibus"
}
