//
//  Handler.swift
//  AppReviews
//
//  Created by Max Chuquimia on 25/2/19.
//  Copyright © 2019 Chuquimian Productions. All rights reserved.
//

import Foundation

class Handler<T> {

    typealias Closure = ((T) -> Void)

    private class WeakRef {

        weak var key: AnyObject?
        let val: Closure

        init(key: AnyObject, value: @escaping Closure) {
            self.key = key
            self.val = value
        }
    }

    private var watchers: [WeakRef] = []
    private let synchronizingQueue = DispatchQueue(label: "handler-operations")

    func value(_ deallocator: AnyObject?, valueHandler: @escaping Closure) {
        guard let deallocator = deallocator else { return }

        // Append the array of watchers
        synchronizingQueue.sync {
            watchers.append(WeakRef(key: deallocator, value: valueHandler))
        }
    }

    func send(_ value: T) {

        synchronizingQueue.sync {
            // Clean up weak references
            watchers = watchers.filter({ $0.key != nil })
        }

        // Notify watchers
        self.watchers.forEach({ $0.val(value) })
    }
}
