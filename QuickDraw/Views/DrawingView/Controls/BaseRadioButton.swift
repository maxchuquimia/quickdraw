//
//  BaseRadioButton.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 28/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

private enum Metrics {
    static let side = 35.f // Static isn't allowed inside generic classes
}

class BaseRadioButton<Item>: RadioButton<Item> {

    override func setup() {
        wantsLayer = true
        layer?.borderWidth = 3

        NSLayoutConstraint.activate(
            widthAnchor.constraint(equalToConstant: Metrics.side),
            heightAnchor.constraint(equalToConstant: Metrics.side)
        )
    }

    override func layout() {
        super.layout()
        layer?.cornerRadius = frame.height / 2.0
    }

    override func styleNormal() {
        needsDisplay = true
        alphaValue = 1.0
    }

    override func styleHover() {
        needsDisplay = true
        alphaValue = 0.5
    }

    override func styleSelected() {
        needsDisplay = true
        alphaValue = 1.0
    }
}
