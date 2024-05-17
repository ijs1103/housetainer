//
//  AppDelegate.swift
//  housetainer-ios
//
//  Created by 이주상 on 2023/11/30.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import NaverThirdPartyLogin
import FirebaseCore
import GoogleSignIn
import Supabase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        KakaoSDK.initSDK(appKey: Env.kakaoAppKey)
        initNaverSDK()
        FirebaseApp.configure()
        RemoteConfigManager.shared.setupRemoteConfig()
        return true
    }
    
    private func initNaverSDK() {
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.isNaverAppOauthEnable = true
        instance?.isInAppOauthEnable = true
        instance?.isOnlyPortraitSupportedInIphone()
        instance?.serviceUrlScheme = kServiceAppUrlScheme
        instance?.consumerKey = kConsumerKey
        instance?.consumerSecret = kConsumerSecret
        instance?.appName = kServiceAppName
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        NaverThirdPartyLoginConnection.getSharedInstance()?.application(app, open: url, options: options)
        var handled: Bool
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
          return true
        }

        return false
    }
}

