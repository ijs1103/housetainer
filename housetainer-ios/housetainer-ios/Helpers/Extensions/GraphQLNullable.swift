//
//  GraphQLNullable.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/15/24.
//

import Foundation
import ApolloAPI

extension GraphQLNullable{
    init(wrap: Wrapped?){
        if let wrap{
            self = .some(wrap)
        }else{
            self = .null
        }
    }
}
