//
//  NSBezierPath+Extension.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 10/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

extension NSBezierPath {

    func lastPoints(upTo count: Int) -> [CGPoint] {

        var output: [CGPoint] = []

        for i in (1..<elementCount) {
            var points = [CGPoint](repeating: .zero, count: 3)

            if element(at: elementCount - i, associatedPoints: &points) == .lineTo {
                output.append(points[0])
            }

            if output.count >= count { break }
        }

        return output
    }
}
