//
//  UITextField+.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/09.
//

import UIKit
import Combine

extension UITextField {
    var publisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap{ $0.object as? UITextField }
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
}
