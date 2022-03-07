//
//  RenderableRect.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 11/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation
import Cocoa

class RenderableRect: Renderable {

    var isHighlight: Bool = true
    let origin: CGPoint

    override var actionName: String {
        return Copy("renderable.type.rectangle")
    }

    required init(origin: CGPoint) {
        self.origin = origin
        super.init(path: NSBezierPath())

        lineWidth = 1
    }

    override func render() {
        super.render()
    }

    override func mouseMoved(to point: CGPoint) {
        super.mouseMoved(to: point)
        path = NSBezierPath(roundedRect: NSRect.from(start: origin, diagonallyOpposite: point), xRadius: 2, yRadius: 2)
    }

}
