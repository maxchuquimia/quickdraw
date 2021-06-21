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

func Log(_ items: Any..., highlighted: Bool = false, file: String = #file) {

    let icon = highlighted ? "🔵" : "⚪️"

    print(items.reduce(icon + logPrefix(file: file), { $0 + " \($1)" }))
}

func LogError(_ items: Any..., file: String = #file) {
    print(items.reduce("🔴" + logPrefix(file: file), { $0 + " \($1)" }))
}

private func logPrefix(file: String) -> String {
    let name = file.components(separatedBy: "/").last?.replacingOccurrences(of: ".swift", with: "") ?? "???"
    return " [\(name)]"
}
