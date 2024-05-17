//
//  Optional+Extension.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/14/24.
//

import Foundation

extension Optional {
    func ifNil(then: Wrapped) -> Wrapped{
        if let self{
            return self
        }
        return then
    }
}
