//
//  RenderableRect.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 11/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation
import Cocoa

final class RenderableRect: Renderable {

    var isHighlight: Bool = true
    var origin: CGPoint

    override var actionName: String {
        Copy("renderable.type.rectangle")
    }

    required init(origin: CGPoint) {
        self.origin = origin
        super.init(path: NSBezierPath())

        lineWidth = 1
    }

    override func mouseMoved(to point: CGPoint) {
        super.mouseMoved(to: point)
        path = NSBezierPath(roundedRect: NSRect.from(start: origin, diagonallyOpposite: point), xRadius: 2, yRadius: 2)
    }

    override func translate(by distance: CGPoint) {
        super.translate(by: distance)
        origin.x += distance.x
        origin.y += distance.y
    }

}
