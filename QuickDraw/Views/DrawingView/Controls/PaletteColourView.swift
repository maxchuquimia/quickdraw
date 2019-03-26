//
//  RoundedLabel.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class PaletteColourView: RadioButton<NSColor> {

    private enum Metrics {
        static let side = 25.f
    }

    override func setup() {
        wantsLayer = true
        layer?.backgroundColor = representedItem.cgColor
        layer?.borderColor = NSColor.white.cgColor

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
        layer?.backgroundColor = representedItem.withAlphaComponent(0.5).cgColor
        needsDisplay = true
    }

    override func styleHover() {
        layer?.backgroundColor = representedItem.withAlphaComponent(0.2).cgColor
        needsDisplay = true
    }

    override func styleSelected() {
        layer?.backgroundColor = representedItem.cgColor
        needsDisplay = true
    }
}
