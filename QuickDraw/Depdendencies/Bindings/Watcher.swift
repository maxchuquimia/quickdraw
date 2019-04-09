//
//  Watcher.swift
//  AppReviews
//
//  Created by Max Chuquimia on 25/2/19.
//  Copyright © 2019 Chuquimian Productions. All rights reserved.
//

import Foundation

enum WatcherError: Error {
    case nilSelf
}

protocol Watcher {
    var deallocator: AnyObject? { get }
}

extension Watcher where Self: AnyObject {
    var deallocator: AnyObject? { return self }

    typealias Function = Self

    /// Generates a block that can be used for `Handler` and `Watcher` callbacks
    /// Use a Tuple if you have multiple arguements (or define another one of these functions)
    ///
    /// - Parameter method: `Function.someMethod(argLabel:)`
    /// - Returns: A value than can be used as a binding, like: `someWatcher += weak(Function.someMethod(argLabel:))`
    func weak<T>(_ method: @escaping ((Function) -> ((T) -> Void))) -> (AnyObject?, ((T) -> Void)) {

        return (deallocator, { [weak self] t in
            guard let `self` = self else { return }
            method(self)(t)
        })
    }

    /// Generates a block that can be used for `Handler<Void>` notification callbacks
    ///
    /// - Parameter method: `Function.someMethod`
    /// - Returns: A value than can be used as a binding, like: `someHandler += weak(Function.someMethod)`
    func weak(_ method: @escaping ((Function) -> (() -> Void))) -> (AnyObject?, (() -> Void)) {

        return (deallocator, { [weak self] in
            guard let `self` = self else { return }
            method(self)()
        })
    }

    /// Generates a block that can be assigned to a `Delegate<T, R>.action` closure.
    /// Throws if `self` is `nil`
    ///
    /// - Parameter method: `Function.someMethod(argLabel:)`
    /// - Returns: the `method` but with a weak reference to `self`
    func weak<T, R>(_ method: @escaping ((Function) -> ((T) -> R))) -> (((T) throws -> R)) {

        return ({ [weak self] t throws -> R in
            guard let `self` = self else { throw WatcherError.nilSelf }
            return method(self)(t)
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
