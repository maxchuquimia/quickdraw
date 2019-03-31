//
//  RenderableLine.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class RenderableLine: Renderable {

    let isArrow: Bool
    private var arrowHead = NSBezierPath()

    override var actionName: String {
        if isArrow {
            return Copy("renderable.type.arrow")
        } else {
            return Copy("renderable.type.line")
        }
    }

    override var autoRespondsToFill: Bool { return false }

    required init(origin: CGPoint, isArrow: Bool) {
        self.isArrow = isArrow
        let newPath = NSBezierPath()
        newPath.move(to: origin)
        super.init(path: newPath)
    }

    override func render() {

        defer {
            super.render()
            renderArrow()
        }

        guard didUpdateSinceLastRender else { return }

        // The following is all about the arrow
        guard isArrow else { return }

        // Only show the arrow if we have more than 5 points
        guard path.elementCount > 5 else { return }

        var angles: [CGFloat] = []
        var pre = path.currentPoint

        path.lastPoints(upTo: 20).forEach { (point) in

            let line = Math.Line(from: pre, to: point)

            // If the distance is too short, ignore this. Kind of smooth out the jittering.
            guard line.length > 2 else { return }

            angles.append(line.slope)
            pre = point
        }

        // Find the average slope of the end of the line
        let slope = angles.reduce(0, { $0 + $1 }) / CGFloat(angles.count)

        let arrowTip = path.currentPoint

        // To draw the two base point of the arrow isoceles, imagine a circle with the tip at the center
        let circleAroundTip = Math.Circle(center: arrowTip, radius: 18)
        let arrowLeft = circleAroundTip.point(angle: -slope - (.pi * 0.3))
        let arrowRight = circleAroundTip.point(angle: -slope - (.pi * 0.6))

        arrowHead = NSBezierPath()
        arrowHead.move(to: arrowLeft)
        arrowHead.line(to: arrowTip)
        arrowHead.line(to: arrowRight)

        if fillColor != nil {
            arrowHead.close()
        }
    }

    func renderArrow() {
        guard isArrow else { return }
        arrowHead.fill()
        arrowHead.lineWidth = 3
        arrowHead.lineCapStyle = .round
        arrowHead.stroke()
    }

    override func mouseMoved(to point: CGPoint) {
        super.mouseMoved(to: point)
        path.line(to: point)
    }
}
