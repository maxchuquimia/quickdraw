//
//  URL+Extensions.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 9/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

extension URL {

    var pathByAddingTildeIfPossible: String {

        var components = absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .components(separatedBy: "/")
            .filter({ !$0.isEmpty })

        var output: String

        if components.first == "Users" && components.count >= 2 {
            components.removeFirst(2)
            output = "~/" + components.joined(separator: "/")
        } else {
            output = components.joined(separator: "/")
        }

        output = output.replacingOccurrences(of: "%20", with: " ")

        return output
    }

}

extension URL: ExpressibleByStringLiteral {

    public typealias StringLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }

}
