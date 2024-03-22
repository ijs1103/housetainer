//
//  ApolloClient+Concurrency.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/29/24.
//

import Foundation
import Apollo
import ApolloAPI

extension ApolloClient{
    func fetch<Query: GraphQLQuery>(query: Query,
                                    cachePolicy: CachePolicy = .fetchIgnoringCacheCompletely,
                                    contextIdentifier: UUID? = nil,
                                    context: RequestContext? = nil,
                                    queue: DispatchQueue = .main) async throws -> Query.Data?{
        let wrapper = ConcurrencyWrapper{ [weak self] (continuation: CheckedContinuation<Query.Data?, Error>) in
            let cancellable = self?.fetch(query: query, cachePolicy: cachePolicy, contextIdentifier: contextIdentifier, context: context, queue: queue, resultHandler: { result in
                switch result{
                case let .success(data):
                    continuation.resume(returning: data.data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            })
            return ClosureCancellable{ cancellable?.cancel() }
        }
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation{ continuation in
                wrapper.resume(with: continuation)
            }
        } onCancel: {
            wrapper.cancel()
        }
    }
    
    func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                            publishResultToStore: Bool = true,
                                            context: RequestContext? = nil,
                                            queue: DispatchQueue = .main) async throws -> Mutation.Data?{
        let wrapper = ConcurrencyWrapper{ [weak self] (continuation: CheckedContinuation<Mutation.Data?, Error>) in
            let cancellable = self?.perform(mutation: mutation, publishResultToStore: publishResultToStore, context: context, resultHandler: { result in
                switch result{
                case let .success(data):
                    continuation.resume(returning: data.data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            })
            return ClosureCancellable{ cancellable?.cancel() }
        }
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation{ continuation in
                wrapper.resume(with: continuation)
            }
        } onCancel: {
            wrapper.cancel()
        }
    }
}
