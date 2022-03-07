//
//  RenderableLine.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class RenderableLine: Renderable {

    enum Metrics {
        static let arrowRadius = 18.f
    }

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

        var angle: CGFloat?

        if isModified {
            guard path.points.count >= 2, let firstPoint = path.points.first, let lastPoint = path.points.last else { return }
            let line = Math.Line(from: firstPoint, to: lastPoint)
            angle = line.slope
        } else {
            // Only draw the arrow head if we have at least x points to average
            for point in path.lastPoints(upTo: 50) {

                let line = Math.Line(from: path.currentPoint, to: point)

                // If the distance is too short, ignore this. Kind of smooth out the jittering.
                guard line.length >= Metrics.arrowRadius else { continue }

                angle = line.slope
                break
            }
        }

        guard let slope = angle else { return }

        let arrowTip = path.currentPoint

        // To draw the two base point of the arrow isoceles, imagine a circle with the tip at the center
        let circleAroundTip = Math.Circle(center: arrowTip, radius: Metrics.arrowRadius)
        let arrowLeft = circleAroundTip.point(angle: -slope - (.pi * 0.35))
        let arrowRight = circleAroundTip.point(angle: -slope - (.pi * 0.65))

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

    override func pathToRender() -> NSBezierPath {

        if isModified {
            // Make this into a straight line using the first and last points
            guard let firstPoint = path.points.first, let lastPoint = path.points.last else { return super.pathToRender() }
            let straightPath = NSBezierPath()
            straightPath.move(to: firstPoint)
            straightPath.line(to: lastPoint)
            return straightPath
        } else {
            return super.pathToRender()
        }
    }

    override func intersects(point: CGPoint) -> Bool {
        var points = path.points
        guard points.count >= 2 else { return false }
        var tolerance = lineWidth

        if isModified {
            // Straight line mode, only use the first and last points
            points = [points.first!, points.last!]
            // Reduce the tolerance as the distance formula below behaves differently with points that are so far from eachother
            tolerance = 0.1
        }

        for (ida, idb) in (0..<points.count - 1).map({ ($0, $0 + 1) }) {
            let ida = points[ida]
            let idb = points[idb]
            let segmentLength = Math.Line(from: ida, to: idb).length
            let partialLengthA = Math.Line(from: ida, to: point).length
            let partialLengthB = Math.Line(from: idb, to: point).length
            let computedLength = partialLengthA + partialLengthB
            if computedLength >= (segmentLength - tolerance) && computedLength <= (segmentLength + tolerance)  {
                return true
            }
        }

        return false
    }

}
