//
//  Cache.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 3/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {

    private var data: [Key: Value] = [:]

    subscript(key: Key) -> Value? {
        set(newValue) {
            data[key] = newValue
        }
        get {
            return data[key]
        }
    }
}
