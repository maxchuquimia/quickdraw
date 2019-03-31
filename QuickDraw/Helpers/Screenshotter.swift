//
//  Screenshotter.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 31/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

struct Screenshotter {

    static func capture(screen: NSScreen)  {

        let filename = "Quick Draw \(Date().as(.screenshot))"

        let destinationURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent(filename)
            .appendingPathExtension("png")

        guard let identifier = screen.deviceDescription[.init("NSScreenNumber")] as? NSNumber else { return }
        let displayId = CGDirectDisplayID(identifier.int32Value)
        guard let screenshot = CGDisplayCreateImage(displayId) else { return }

        guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return }
        CGImageDestinationAddImage(destination, screenshot, nil)
        CGImageDestinationFinalize(destination)
    }
}
