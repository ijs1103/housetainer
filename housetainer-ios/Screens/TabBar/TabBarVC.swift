//
//  TabBarVC.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/18.
//

import UIKit

final class TabBarVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setTabBar()
        setShadow()
    }
}

extension TabBarVC: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let isNeverVC = (viewController is NeverViewController)
        if isNeverVC{
            let createSocialCalendarVC = CreateSocialCalendarVC()
            let createSocialNavVC = UINavigationController(rootViewController: createSocialCalendarVC)
            createSocialNavVC.modalPresentationStyle = .fullScreen
            present(createSocialNavVC, animated: true)
        }
        return !isNeverVC
    }
}

extension TabBarVC {
    private func setTabBar() {
        let tabBarViewControllers: [UIViewController] = TabBarItem.allCases
            .map { tabCase in
                let viewController = tabCase.viewController
                viewController.tabBarItem = UITabBarItem(
                    title: tabCase.title,
                    image: tabCase.icon.default,
                    selectedImage: tabCase.icon.selected?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal) // withRenderingMode(UIImage.RenderingMode.alwaysOriginal): 선택된 이미지에 tint color를 적용시키지 않고 원래 이미지 그대로 사용하도록 하는 모드
                )
                return viewController
            }
        self.viewControllers = tabBarViewControllers
    }
    private func setShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
        
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 6.0
        tabBar.layer.shadowPath = UIBezierPath(rect: tabBar.layer.bounds).cgPath
    }
}
