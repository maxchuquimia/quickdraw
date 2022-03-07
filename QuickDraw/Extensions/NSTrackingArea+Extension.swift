//
//  NSTrackingArea+Extension.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 26/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

extension NSTrackingArea {

    static func standardTrackingArea(for view: NSView) -> NSTrackingArea {
        return NSTrackingArea(rect: view.bounds, options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited, .mouseMoved], owner: view, userInfo: nil)
    }

    static func setup(in view: NSView) {
        view.trackingAreas.forEach(view.removeTrackingArea(_:))
        view.addTrackingArea(standardTrackingArea(for: view))
    }

}
