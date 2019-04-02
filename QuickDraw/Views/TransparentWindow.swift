//
//  TransparentWindow.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 3/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class TransparentWindow: NSWindow, Watcher {

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = NSColor.white.withAlphaComponent(0.01)
        isOpaque = false
        isMovable = false

        toolbar?.allowsUserCustomization = false
        toolbar?.allowsExtensionItems = false

        toolbar?.items.forEach({ (item) in
            item.menuFormRepresentation = nil
        })

        guard let screen = NSScreen.main else { return }
        setFrame(screen.visibleFrame, display: true)
    }
}
