//
//  Rect.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 11/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

extension NSRect {
    static func from(start: NSPoint, diagonallyOpposite end: NSPoint) -> NSRect {
        return NSRect(x: min(start.x, end.x), y: min(start.y, end.y), width: abs(start.x - end.x), height: abs(start.y - end.y))
    }
}
