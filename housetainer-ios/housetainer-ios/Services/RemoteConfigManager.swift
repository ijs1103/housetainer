//
//  RemoteConfig.swift
//  housetainer-ios
//
//  Created by 이주상 on 5/3/24.
//

import Firebase

final class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    private init() {}

    struct ConfigData {
        let supabaseUrl: URL
        let supabaseAnonKey: String
        let needSignupInvitation: Bool
        let checkLatestVersion: Bool
    }

    private(set) var data: ConfigData = ConfigData(supabaseUrl: Env.supabaseURL, supabaseAnonKey: Env.supabaseKey, needSignupInvitation: false, checkLatestVersion: false)

    func setupRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 300
        remoteConfig.configSettings = settings

        remoteConfig.fetch { [weak self] status, error in
            if status == .success {
                remoteConfig.activate { [weak self] changed, error in
                    guard let self = self else { return }
                    let supabaseUrl = URL(string: remoteConfig.configValue(forKey: "supabase_url").stringValue ?? "") ?? Env.supabaseURL
                    let supabaseAnonKey = remoteConfig.configValue(forKey: "supabase_anon_key").stringValue ?? Env.supabaseKey
                    let needSignupInvitation = remoteConfig.configValue(forKey: "need_signup_invitation").boolValue
                    let checkLatestVersion = remoteConfig.configValue(forKey: "check_latest_version").boolValue
                    self.data = changed ? ConfigData(supabaseUrl: data.supabaseUrl, supabaseAnonKey: data.supabaseAnonKey, needSignupInvitation: data.needSignupInvitation, checkLatestVersion: checkLatestVersion) : ConfigData(supabaseUrl: supabaseUrl, supabaseAnonKey: supabaseAnonKey, needSignupInvitation: needSignupInvitation, checkLatestVersion: checkLatestVersion)
                    print(data)
                    if checkLatestVersion {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .checkLatestVersion, object: nil, userInfo: ["checkLatestVersion": checkLatestVersion])
                        }
                    }
                    if let StringVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, let version = Float(StringVersion) {
                        print("앱 버전: \(version)")
                    }
                }
            } else {
                print(error?.localizedDescription ?? "setupRemoteConfig - fetching error")
            }
        }
    }
}
