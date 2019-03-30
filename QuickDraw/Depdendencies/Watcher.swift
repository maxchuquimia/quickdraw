//
//  Watcher.swift
//  AppReviews
//
//  Created by Max Chuquimia on 25/2/19.
//  Copyright © 2019 Chuquimian Productions. All rights reserved.
//

import Foundation

protocol Watcher {
    var deallocator: AnyObject? { get }
}

extension Watcher where Self: AnyObject {
    var deallocator: AnyObject? { return self }

    typealias Function = Self

    func weak<T>(_ method: @escaping ((Function) -> ((T) -> Void))) -> (AnyObject?, ((T) -> Void)) {

        return (deallocator, { [weak self] t in
            guard let `self` = self else { return }
            method(self)(t)
        })
    }

    func weak(_ method: @escaping ((Function) -> (() -> Void))) -> (AnyObject?, (() -> Void)) {

        return (deallocator, { [weak self] in
            guard let `self` = self else { return }
            method(self)()
        })
    }
}

infix operator +=: AssignmentPrecedence

/// Binds a function to the update notifications. The function will be called asynchronously on the calling thread.
/// This may result in unexpected behaviour if multiple values are sent in quick succession; i.e.
/// ```
/// func f() {
///   handler.send(a); handler.send(b); handler.send(c);
/// }
/// ```
/// may result in three `c` notifications being receieved by a `Watcher`
func +=<T>(handler: Handler<T>, value: (AnyObject?, ((T) -> Void))) {
    handler.value(value)
}

func +=(handler: Handler<Void>, value: (AnyObject?, (() -> Void))) {
    handler.value(value.0, valueHandler: {_ in
        value.1()
    })
}

private extension Handler {

    func value(_ binding: (AnyObject?, ((T) -> Void))) {
        let queue = OperationQueue.current?.underlyingQueue
        self.value(binding.0, valueHandler: { v in

            if queue == OperationQueue.current?.underlyingQueue {
                binding.1(v)
            } else {
                queue?.async { binding.1(v) }
            }
        })
    }
}
