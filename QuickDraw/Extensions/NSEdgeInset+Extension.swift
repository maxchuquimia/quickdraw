//
//  NSEdgeInset+Extension.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 30/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

extension NSEdgeInsets {

    static func allEdges(_ d: CGFloat) -> NSEdgeInsets {
        return NSEdgeInsets(top: d, left: d, bottom: d, right: d)
    }

}
