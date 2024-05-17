//
//  ConcurrencyWrapper.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/17/24.
//

import Foundation
import Combine

final class ConcurrencyWrapper<T, E: Error>{
    private var cancellable: Cancellable?
    private let builder: ((CheckedContinuation<T, E>) -> Cancellable?)
    
    init(_ builder: @escaping (CheckedContinuation<T, E>) -> Cancellable?){
        self.builder = builder
    }
    
    func resume(with continuation: CheckedContinuation<T, E>){
        cancellable = builder(continuation)
    }
    
    func cancel(){
        cancellable?.cancel()
    }
}

final class ClosureCancellable: Cancellable{
    let closure: (() -> Void)
    
    init(closure: @escaping (() -> Void)){
        self.closure = closure
    }
    
    deinit{
        cancel()
    }
    
    func cancel() {
        closure()
    }
}
