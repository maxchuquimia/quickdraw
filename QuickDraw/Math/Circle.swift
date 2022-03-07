//
//  Circle.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 10/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

extension Math {

    struct Circle {
        let center: CGPoint
        let radius: CGFloat

        func point(angle: CGFloat) -> CGPoint {
            CGPoint(
                x: (radius * sin(angle)) + center.x,
                y: (radius * cos(angle)) + center.y
            )
        }

        func points(count: Int, offset: CGFloat) -> [CGPoint] {
            let sectorLength = 2.0 * .pi / CGFloat(count)

            return (0..<count).map({ (sectorIndex) -> CGPoint in
                let idx = CGFloat(sectorIndex)
                let x = center.x + radius * cos((sectorLength * idx) + offset)
                let y = center.y + radius * sin((sectorLength * idx) + offset)
                return CGPoint(x: x, y: y)
            })
        }

        var frame: CGRect {
            CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2.0, height: radius * 2.0)
        }
    }

}
