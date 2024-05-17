//
//  TabBarItem.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/18.
//

import UIKit

enum TabBarItem: CaseIterable {
    case home
    case schedule
    case my
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .schedule:
            return "Schedule"
        case .my:
            return "MY"
        }
    }
    
    var icon: (default: UIImage?, selected: UIImage?) {
        switch self {
        case .home:
            return (Icon.homeTabActive, Icon.homeTabActive)
        case .schedule:
            return (Icon.dateupTabActive, Icon.dateupTabActive)
        case .my:
            return (Icon.myTabActive, Icon.myTabActive)
        }
    }

    var viewController: UIViewController {
        switch self {
        case .home:
            return UINavigationController(rootViewController: MainVC())
        case .schedule:
            return NeverViewController()
        case .my:
            return UINavigationController(rootViewController: MyPageVC())
        }
    }
}

final class NeverViewController: UIViewController {}
