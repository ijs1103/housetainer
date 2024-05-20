//
//  SceneDelegate.swift
//  housetainer-ios
//
//  Created by 이주상 on 2023/11/30.
//

import UIKit
import KakaoSDKAuth
import NaverThirdPartyLogin
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: Typo.Body5(), NSAttributedString.Key.foregroundColor: Color.gray600]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font: Typo.Body5(), NSAttributedString.Key.foregroundColor: Color.black]
        UITabBar.appearance().standardAppearance = appearance
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        setupNavigationBar()
        setupTabBar()
        self.window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.window?.rootViewController = TabBarVC()
        }
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
        NaverThirdPartyLoginConnection
            .getSharedInstance()?
            .receiveAccessToken(URLContexts.first?.url)
    }
    
}

