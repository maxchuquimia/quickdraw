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

    // i.e. should this be rendered as if Shift were held down?
    var isModified = false

    /// For the Undo menu
    var actionName: String { die() }

    /// If the receiver has recieved a `mouseMoved(to:)` call since the last time `render()` was called, this will be `true`
    private(set) var didUpdateSinceLastRender = false

    var autoRespondsToFill: Bool { true }

    init(path: NSBezierPath) {
        self.path = path
    }

    func render() {
        let path = pathToRender()

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

    func pathToRender() -> NSBezierPath {
        path
    }

    func intersects(point: CGPoint) -> Bool {
        path.contains(point)
    }

}
