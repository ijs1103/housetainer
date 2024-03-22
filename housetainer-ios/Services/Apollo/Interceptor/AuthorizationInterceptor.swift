//
//  AuthorizationInterceptor.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/29/24.
//

import Foundation
import Apollo
import ApolloAPI
import Supabase

final class AuthorizationInterceptor: ApolloInterceptor{
    let id: String
    
    init(){
        self.id = Bundle(for: Self.self).bundleIdentifier! + ".AuthorizationInterceptor"
    }
    
    func interceptAsync<Operation>(chain: RequestChain, request: HTTPRequest<Operation>, response: HTTPResponse<Operation>?, completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) where Operation : GraphQLOperation {
        Task{
            do{
                let session = try await SupabaseClient.shared.auth.session
                request.addHeader(name: "Authorization", value: "Bearer \(session.accessToken)")
                chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
            }catch{
                completion(.failure(error))
            }
        }
    }
}
