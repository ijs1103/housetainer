//
//  ButtonFactory.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/10.
//

import UIKit

struct MyButtonConfig {
    let title: String
    let font: UIFont
    let textColor: UIColor
    let bgColor: UIColor
}

struct ButtonFactory {
    static func build(config: MyButtonConfig) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.baseForegroundColor = config.textColor
        configuration.baseBackgroundColor = config.bgColor
        var titleContainer = AttributeContainer()
        titleContainer.font = config.font
        titleContainer.foregroundColor = config.textColor
        configuration.attributedTitle = AttributedString(config.title, attributes: titleContainer)
        let button = UIButton(configuration: configuration)
        let colorImage = config.bgColor.image()
        button.setBackgroundImage(colorImage, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true 
        return button
    }
    
    static func buildOutline(config: MyButtonConfig, borderColor: UIColor) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        var background = UIButton.Configuration.plain().background
        background.cornerRadius = 8
        background.strokeWidth = 1
        background.strokeColor = borderColor
        configuration.background = background
        configuration.baseBackgroundColor = config.bgColor
        configuration.baseForegroundColor = config.textColor
        var titleContainer = AttributeContainer()
        titleContainer.font = config.font
        configuration.attributedTitle = AttributedString(config.title, attributes: titleContainer)
        let button = UIButton(configuration: configuration)
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        return button
    }
}
