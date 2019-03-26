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
        return "Arrow"
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

        // this should only choose points far-ish away from eachother
        var angles: [CGFloat] = []
        var pre = path.currentPoint

        path.lastPoints(upTo: 40).forEach { (point) in

            let slope = atan2(pre.y - point.y, pre.x - point.x)
            angles.append(slope)
            pre = point
        }


//        let arrowCalculationCount = min(path.elementCount, 40)
//
//        (1..<arrowCalculationCount).forEach { (i) in
//
//            var points = [CGPoint](repeating: .zero, count: 3)
//            path.element(at: path.elementCount - i, associatedPoints: &points)
//            let slope = atan2(pre.y - points[0].y, pre.x - points[0].x)
//            angles.append(slope)
//
//            pre = points[0]
//        }

        // Find the average slope of the line
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
