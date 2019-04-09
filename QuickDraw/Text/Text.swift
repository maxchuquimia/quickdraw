//
//  Text.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 28/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class Text: AttributedStringGenerator {
    private(set) var _font: NSFont = .systemFont(ofSize: 12)
    private(set) var _color: NSColor = .black
    private(set) var _link: URL?

    let string: String

    var attributes: [NSAttributedString.Key : Any] {

        var attributes: [NSAttributedString.Key : Any] = [
            .font : _font,
            .foregroundColor: _color
        ]

        if let link = _link {
            attributes[.link] = link
        }

        return attributes
    }

    var attributedString: NSAttributedString {

        let attributedString = NSMutableAttributedString(
            string: string,
            attributes: attributes
        )

        return attributedString.copy() as! NSAttributedString
    }

    init(_ string: String) {
        self.string = string
    }

    convenience init(copy string: String) {
        self.init(Copy(string))
    }

    convenience init?(_ string: String?) {
        guard let string = string else { return nil }
        self.init(string)
    }

    func font(_ font: NSFont) -> Self {
        _font = font
        return self
    }

    func color(_ color: NSColor) -> Self {
        _color = color
        return self
    }

    func link(_ link: URL) -> Self {
        _link = link
        return self
    }
}

class TextComposition: AttributedStringGenerator {

    let attributedString: NSAttributedString
    let attributes: [NSAttributedString.Key : Any]

    init(_ a: NSAttributedString, _ b: NSAttributedString, _ attributes: [NSAttributedString.Key : Any]) {
        let s = (a.mutableCopy() as! NSMutableAttributedString)
        s.append(b)
        self.attributedString = s.copy() as! NSAttributedString
        self.attributes = attributes
    }
}
