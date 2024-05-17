//
//  AlertBuilder.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/14/24.
//

import UIKit

final class AlertBuilder {
    private var style: UIAlertController.Style = .alert
    private var title: String?
    private var message: String?
    private var actions: [UIAlertAction] = []
    
    func setStyleToActionSheet() -> AlertBuilder {
        self.style = .actionSheet
        return self
    }

    func setTitle(_ title: String) -> AlertBuilder {
        self.title = title
        return self
    }

    func setMessage(_ message: String) -> AlertBuilder {
        self.message = message
        return self
    }

    func addAction(title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) -> AlertBuilder {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        actions.append(action)
        return self
    }

    func build() -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { alert.addAction($0) }
        return alert
    }
}
