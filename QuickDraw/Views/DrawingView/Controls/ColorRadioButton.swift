//
//  ColorRadioButton.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

final class ColorRadioButton: BaseRadioButton<NSColor> {

    override func setup() {
        super.setup()
        layer?.borderColor = representedItem.cgColor
    }

    override func styleNormal() {
        super.styleNormal()
        layer?.backgroundColor = NSColor.white.cgColor
    }

    override func styleSelected() {
        super.styleSelected()
        layer?.backgroundColor = representedItem.cgColor
    }

}
