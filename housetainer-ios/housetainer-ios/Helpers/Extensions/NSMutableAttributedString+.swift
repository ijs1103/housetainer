//
//  NSMutableAttributedString+.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/13.
//

import UIKit

extension NSMutableAttributedString {
    func regularLabel(string: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.font: Typo.Body3(), .foregroundColor: Color.gray600]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    func requiredLabel() -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.font: Typo.Body3(), .foregroundColor: Color.red200]
        self.append(NSAttributedString(string: "*", attributes: attributes))
        return self
    }
    
    func requirementLabel() -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.font: Typo.Body3(), .foregroundColor: Color.gray500]
        self.append(NSAttributedString(string: " (필수)", attributes: attributes))
        return self
    }
    
    func underlined(string: String, font: UIFont, textColor: UIColor = .black, lineColor: UIColor = .black) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font: font,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: textColor,
            .underlineColor: lineColor
        ]
        self.append(NSAttributedString(string: string, attributes:attributes))
        return self
    }
    
    func gridSectionTitle(string: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.font: Typo.Heading3(), .foregroundColor: Color.purple400]
        self.append(NSAttributedString(string: string, attributes: attributes))
        let pickAttributes: [NSAttributedString.Key: Any] = [.font: Typo.Heading3(), .foregroundColor: UIColor.black]
        self.append(NSAttributedString(string: " PICK", attributes: pickAttributes))
        return self
    }
}
