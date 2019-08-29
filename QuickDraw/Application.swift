//
//  Application.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 29/8/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

@objc(CustomApplication)
class CustomApplication: NSApplication {

    override func sendEvent(_ event: NSEvent) {

        if event.type == .keyDown {
            if event.modifierFlags.contains(.command) {
                if event.charactersIgnoringModifiers == "c" {
                    // Always responds to a Command+C to copy
                    // Not sure why Command+S doesn't need this...
                    NotificationCenter.copyButtonPressed.send()
                }
            }
        }

        super.sendEvent(event)
    }
}
