//
//  General.swift
//  AppReviews
//
//  Created by Max Chuquimia on 27/2/19.
//  Copyright © 2019 Chuquimian Productions. All rights reserved.
//

import Foundation

func die(file: String = #file, function: String = #function, line: Int = #line) -> Never {
    fatalError("\(file):\(function):\(line)")
}

func Log(_ items: Any..., highlighted: Bool = false) {

    let icon = highlighted ? "🔵" : "⚪️"

    print(items.reduce(icon, { $0 + " \($1)" }))
}

func LogError(_ items: Any...) {
    print(items.reduce("🔴", { $0 + " \($1)" }))
}
