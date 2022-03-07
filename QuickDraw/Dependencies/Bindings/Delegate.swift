//
//  Delegate.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 7/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

final class Delegate<Arguments, ReturnValue> {

    typealias Closure = ((Arguments) throws -> ReturnValue)

    private let defaultValue: ReturnValue
    var action: Closure

    init(_ defaultValue: ReturnValue) {
        self.defaultValue = defaultValue
        self.action = { _ in return defaultValue }
    }

    func execute(_ args: Arguments) -> ReturnValue {
        guard let returnValue = try? action(args) else { return defaultValue }
        return returnValue
    }

}
