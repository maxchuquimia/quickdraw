//
//  RenderableCircle.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 12/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

final class RenderableCircle: Renderable {

    private var center: CGPoint

    override var actionName: String {
        Copy("renderable.type.circle")
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

    override func translate(by distance: CGPoint) {
        super.translate(by: distance)
        center.x += distance.x
        center.y += distance.y
    }

}
