//
//  Cancellable.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/15/24.
//

import Foundation
import Combine

extension Task {
    func store(in collections: inout [AnyCancellable]){
        AnyCancellable(cancel).store(in: &collections)
    }
}
