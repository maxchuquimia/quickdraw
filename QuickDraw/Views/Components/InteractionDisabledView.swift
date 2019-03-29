//
//  InteractionDisabledView.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 29/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class InteractionDisabledView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { return  nil }
}
