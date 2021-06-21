//
//  Storable.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 9/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

// MARK: - Protocol
protocol StoredObject {
    associatedtype Primitive
    func toPrimitive() -> Primitive?
    static func from(primitive: Primitive) -> Self?
}

// MARK: - Storable Types
extension String: StoredAsSelf  {
    typealias Primitive = String
}

extension Bool: StoredAsSelf  {
    typealias Primitive = Bool
}

extension Int: StoredAsSelf  {
    typealias Primitive = Int
}

extension CGFloat: StoredAsSelf  {
    typealias Primitive = CGFloat
}

extension Data: StoredAsSelf  {
    typealias Primitive = Data
}

extension Array: StoredObject  {
    typealias Primitive = Data

    func toPrimitive() -> Primitive? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }

    static func from(primitive: Primitive) -> Array<Element>? {
        let dict = try? JSONSerialization.jsonObject(with: primitive, options: [])
        return dict as? Array<Element>
    }
}

// If you want more types:
//extension Int: StoredObject  {
//    typealias Primitive = Int
//}

// MARK: - Boilerplate

protocol StoredAsSelf: StoredObject where Primitive == Self { }

extension StoredAsSelf {
    func toPrimitive() -> Primitive? { return self }
    static func from(primitive: Primitive) -> Primitive? { return primitive }
}

protocol StringLiteralBoilerplate {
    init(stringLiteral value: String)
}

extension StringLiteralBoilerplate {
    typealias StringLiteralType = String

    init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }

    init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

// MARK: - Implementation
struct Storable<Object>: ExpressibleByStringLiteral, StringLiteralBoilerplate where Object: StoredObject {

    private let key: String
    private let store = UserDefaults.standard

    init(stringLiteral value: String) {
        self.key = value
    }

    var value: Object? {
        set {
            store.set(newValue?.toPrimitive(), forKey: key)
        }
        get {
            guard let p = store.value(forKey: key) as? Object.Primitive else { return nil }
            return Object.from(primitive: p)
        }
    }
}
