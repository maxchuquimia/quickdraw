//
//  Text.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 28/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class Text {
    private(set) var font: NSFont = .systemFont(ofSize: 12)
    private(set) var color: NSColor = .black

    let string: String

    var attributedString: NSAttributedString {

        let attributedString = NSMutableAttributedString(
            string: string,
            attributes: [
                .font : font,
                .foregroundColor: color
            ]
        )

        return attributedString.copy() as! NSAttributedString
    }

    init(_ string: String) {
        self.string = string
    }

    init?(_ string: String?) {
        guard let string = string else { return nil }
        self.string = string
    }

    func font(_ font: NSFont) -> Self {
        self.font = font
        return self
    }

    func color(_ color: NSColor) -> Self {
        self.color = color
        return self
    }
}
