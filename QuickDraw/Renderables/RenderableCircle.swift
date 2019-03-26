//
//  RenderableCircle.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 12/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class RenderableCircle: Renderable {

    private let center: CGPoint

    override var actionName: String {
        return "Circle"
    }

    required init(center: CGPoint) {
        self.center = center
        let newPath = NSBezierPath()
        super.init(path: newPath)
    }

    override func mouseMoved(to point: CGPoint) {
        super.mouseMoved(to: point)

        let radius = Math.Line(from: center, to: point).length
        let circle = Math.Circle(center: center, radius: radius)
        path = NSBezierPath(ovalIn: circle.frame)
    }
}
