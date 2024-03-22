//
//  ApolloInterceptorProvider.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/29/24.
//

import Foundation
import Apollo
import ApolloAPI

final class ApolloInterceptorProvider: DefaultInterceptorProvider {
    
    override func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> [any ApolloInterceptor] {
        return [
            AuthorizationInterceptor()
        ] + super.interceptors(for: operation)
    }
}
