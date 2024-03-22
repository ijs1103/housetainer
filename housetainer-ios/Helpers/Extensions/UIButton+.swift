//
//  UIButton+.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/28/24.
//

import UIKit

extension UIButton {
    func changeAttributedTitle(text: String? = nil, textColor: UIColor) {
        var newConfiguration = self.configuration
        var attributes = AttributeContainer()
        attributes.font = Typo.Title4()
        attributes.foregroundColor = textColor
        newConfiguration?.attributedTitle = AttributedString(text ?? self.configuration?.title ?? "", attributes: attributes)
        self.configuration = newConfiguration
    }
    
    func toggleEnabledState(textToChange: String? = nil, _ isEnabled: Bool) {
        if isEnabled {
            self.configuration?.baseBackgroundColor = Color.purple400
            self.changeAttributedTitle(text: textToChange, textColor: .white)
        } else {
            self.configuration?.baseBackgroundColor = Color.gray200
            self.changeAttributedTitle(text: textToChange, textColor: Color.gray500)
        }
        self.isEnabled = isEnabled
    }
}
