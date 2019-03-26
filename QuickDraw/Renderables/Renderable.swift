//
//  Renderable.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class Renderable {

    var path: NSBezierPath
    var strokeColor: NSColor? = .white
    var fillColor: NSColor? = nil
    var lineWidth: CGFloat = 3

    /// For the Undo menu
    var actionName: String { die() }

    /// If the receiver has recieved a `mouseMoved(to:)` call since the last time `render()` was called, this will be `true`
    private(set) var didUpdateSinceLastRender = false

    var autoRespondsToFill: Bool { return true }

    init(path: NSBezierPath) {
        self.path = path
    }

    func render() {
        fillColor?.setFill()
        strokeColor?.setStroke()

        if fillColor != nil, autoRespondsToFill {
            path.fill()
        }

        if strokeColor != nil {
            path.lineWidth = lineWidth
            path.stroke()
        }

        didUpdateSinceLastRender = false
    }

    func mouseMoved(to point: CGPoint) {
        didUpdateSinceLastRender = true
    }
}
