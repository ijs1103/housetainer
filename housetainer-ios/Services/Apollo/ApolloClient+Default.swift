//
//  ApolloClient+Default.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/21/24.
//

import Foundation
import Apollo
import Supabase
import ApolloAPI

private enum ApolloConfiguration{
    static let endpointURL = URL(string: Configuration.SupabaseGraphQLEndpointUrl)!
    static let apiKey: String = Configuration.SupabaseApiKey
}

extension ApolloClient{
    static let shared = {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let transport = RequestChainNetworkTransport(
            interceptorProvider: ApolloInterceptorProvider(shouldInvalidateClientOnDeinit: true, store: store),
            endpointURL: ApolloConfiguration.endpointURL,
            additionalHeaders: [
                "apikey": ApolloConfiguration.apiKey
            ])
        return ApolloClient(networkTransport: transport, store: store)
    }()
}
