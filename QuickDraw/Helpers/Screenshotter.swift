//
//  Screenshotter.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 31/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class Screenshotter: Watcher {

    static let shared = Screenshotter()
    private(set) var lastScreenshotLocation: URL?

    init() {
        NotificationCenter.screenshotSuccessNotificationPressed += weak(Function.screenshotPressed)
    }

    func capture(screen: NSScreen) {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()

        let filename = "Quick Draw \(Date().as(.screenshot))"

        let destinationURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Downloads")
            .appendingPathComponent(filename)
            .appendingPathExtension("png")

        var success = false

        defer {
            if success {
                lastScreenshotLocation = destinationURL
                playSound()
                showSuccessNotification()
            }  else {
                showFailedNotification()
            }
        }

        guard let identifier = screen.deviceDescription[.init("NSScreenNumber")] as? NSNumber else { return }
        let displayId = CGDirectDisplayID(identifier.int32Value)
        guard let screenshot = CGDisplayCreateImage(displayId) else { return }

        guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return }
        CGImageDestinationAddImage(destination, screenshot, nil)
        success = CGImageDestinationFinalize(destination)
    }

    private func showSuccessNotification() {
        let notification = NSUserNotification()
        notification.title = Copy("screenshot.notification.title")
        notification.informativeText = Copy("screenshot.notification.success", lastScreenshotLocation?.lastPathComponent ?? "?")
        notification.soundName = nil
        notification.identifier = NotificationDelegate.Identifier.screenshotSuccess.rawValue
        NSUserNotificationCenter.default.deliver(notification)
    }

    private func showFailedNotification() {
        let notification = NSUserNotification()
        notification.title = Copy("screenshot.notification.title")
        notification.informativeText = Copy("screenshot.notification.error")
        notification.soundName = nil
        NSUserNotificationCenter.default.deliver(notification)
    }

    private func playSound() {
        // I found this by running `sudo opensnoop | grep aif` and taking a screenshot 😉
        NSSound(
            contentsOfFile: "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Grab.aif",
            byReference: true
        )?.play()
    }

    private func screenshotPressed() {
        guard let lastLocation = lastScreenshotLocation else { return }
        NSWorkspace.shared.activateFileViewerSelecting([lastLocation])
    }
}
