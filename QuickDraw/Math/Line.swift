//
//  Line.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 11/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

extension Math {

    struct Line {
        let a: CGPoint
        let b: CGPoint
        
        init(from a: CGPoint, to b: CGPoint) {
            self.a = a
            self.b = b
        }
        
        var length: CGFloat {
            sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
        }
        
        var slope: CGFloat {
            atan2(a.y - b.y, a.x - b.x)
        }

        var midpoint: CGPoint {
            CGPoint(x: (a.x - b.x) / 2, y: (a.y - b.y) / 2)
        }
        
        func point(distanceFromA: CGFloat) -> CGPoint {
            let circle = Circle(center: a, radius: distanceFromA)
            return circle.points(count: 1, offset:  slope).first!
        }
        
        // Modified version of https://stackoverflow.com/a/45931831/1153630
        func intersectionPoint(with line2: Line) throws -> CGPoint {
            
            enum Errors: Error {
                case parallel
                case intersectionError
            }
            
            let distance = (self.b.x - self.a.x) * (line2.b.y - line2.a.y) - (self.b.y - self.a.y) * (line2.b.x - line2.a.x)
            if distance == 0 {
                throw Errors.parallel
            }
            
            let u = ((line2.a.x - self.a.x) * (line2.b.y - line2.a.y) - (line2.a.y - self.a.y) * (line2.b.x - line2.a.x)) / distance
            let v = ((line2.a.x - self.a.x) * (self.b.y - self.a.y) - (line2.a.y - self.a.y) * (self.b.x - self.a.x)) / distance
            
            if (u < 0.0 || u > 1.0) {
                throw Errors.intersectionError
            }
            if (v < 0.0 || v > 1.0) {
                throw Errors.intersectionError
            }
            
            return CGPoint(x: self.a.x + u * (self.b.x - self.a.x), y: self.a.y + u * (self.b.y - self.a.y))
        }

    }

}
