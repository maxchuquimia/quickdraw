//
//  TextExtensions.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 30/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

extension NSTextField {

    convenience init(label: Text) {
        self.init(labelWithAttributedString: label.attributedString)
    }
}
