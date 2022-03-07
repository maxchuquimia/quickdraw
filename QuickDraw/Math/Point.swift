//
//  Point.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 13/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

extension NSPoint {

    func offset(x: CGFloat = 0, y: CGFloat = 0) -> NSPoint {
        NSPoint(x: self.x + x, y: self.y + y)
    }

}
