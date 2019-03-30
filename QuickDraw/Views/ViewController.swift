//
//  ViewController.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

//let displayID = CGMainDisplayID()
//let imageRef = CGDisplayCreateImage(displayID)
//        FileManager.default.homeDirectoryForCurrentUser

class TransparentWindow: NSWindow {

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

        setFrame(NSScreen.main!.visibleFrame, display: true)
    }
}

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

