//
//  Watchable.swift
//  AppReviews
//
//  Created by Max Chuquimia on 21/2/19.
//  Copyright © 2019 Chuquimian Productions. All rights reserved.
//

import Foundation

final class Watchable<T>: Handler<T>  {

    var value: T {
        didSet {
            // guard value != oldValue else { return }
            notifyWatchers()
        }
    }

    init(_ value: T) {
        self.value = value
    }

    override func value(_ deallocator: AnyObject?, valueHandler: @escaping ((T) -> Void)) {
        super.value(deallocator, valueHandler: valueHandler)

        // Notifer the watcher of the value immediately
        valueHandler(self.value)
    }

    private func notifyWatchers() {
        super.send(value) // call the superclass implementation
    }

    // Prefferably don't use this - set `value` instead
    override func send(_ value: T) {
        self.value = value // This will trigger the superclass implementation
    }

    /// Call to send the last event again (useful if T contains mutated objects)
    func update() {
        notifyWatchers()
    }
}

