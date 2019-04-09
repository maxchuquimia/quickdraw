//
//  AttributedStringGenerator.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 9/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

protocol AttributedStringGenerator {
    var attributedString: NSAttributedString { get }
    var attributes: [NSAttributedString.Key : Any] { get }
}

extension AttributedStringGenerator {
    var attributes: [NSAttributedString.Key : Any] {
        return [:]
    }
}

func +(a: AttributedStringGenerator, b: AttributedStringGenerator) -> TextComposition {
    var newAttributes = a.attributes
    b.attributes.forEach({ newAttributes[$0.0] = $0.1 })
    return TextComposition(a.attributedString, b.attributedString, newAttributes)
}
