//
//  Screenshotter.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 31/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

final class Screenshotter: Watcher {

    static let shared = Screenshotter()
    private(set) var lastScreenshotLocation: URL?
    let configureForScreenshotHandler: Handler<Bool> = .init()
    let screenshotLocationChangedHandler: Handler<Void> = .init()

    private init() {
        NotificationCenter.screenshotSuccessNotificationPressed += weak(Function.screenshotPressed)
    }

    func capture(screen: NSScreen) {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()

        let filename = "Quick Draw \(Date().as(.screenshot))"

        var screenshotDirectory = self.screenshotDirectory
        var waitTime: TimeInterval = 0.1

        if screenshotDirectory == nil {
            screenshotDirectory = showLocationPicker()
            // If the NSOpenPanel was shown... we need to wait for it to disappear before the screenshot occurs
            waitTime = 0.3
        }

        guard let directory = screenshotDirectory else {
            showFailedNotification()
            return
        }

        configureForScreenshotHandler.send(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            self.capture(screen: screen, to: directory, named: filename)
            self.configureForScreenshotHandler.send(false)
        }
    }

    func captureToClipboard(screen: NSScreen) {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()

        configureForScreenshotHandler.send(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

            guard let screenshot = self.getImage(of: screen) else { return }
            let image = NSImage(cgImage: screenshot, size: screen.frame.size)
            self.playSound()

            NSPasteboard.general.clearContents()
            NSPasteboard.general.writeObjects([image])

            self.showCopySuccessNotification()

            self.configureForScreenshotHandler.send(false)
        }
    }
    private func capture(screen: NSScreen, to directory: URL, named filename: String) {

        let destinationURL = directory
            .appendingPathComponent(filename)
            .appendingPathExtension("png")

        var success = false

        _ = directory.startAccessingSecurityScopedResource()
        defer {
            directory.stopAccessingSecurityScopedResource()

            if success {
                lastScreenshotLocation = destinationURL
                playSound()
                showSuccessNotification()
            }  else {
                showFailedNotification()
            }
        }

        guard let screenshot = getImage(of: screen) else { return }

        guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return }
        CGImageDestinationAddImage(destination, screenshot, nil)
        success = CGImageDestinationFinalize(destination)
    }

    private func getImage(of screen: NSScreen) -> CGImage? {
        guard let identifier = screen.deviceDescription[.init("NSScreenNumber")] as? NSNumber else { return nil }
        let displayId = CGDirectDisplayID(identifier.int32Value)
        guard let screenshot = CGDisplayCreateImage(displayId) else { return nil }
        return screenshot
    }

    private func showSuccessNotification() {
        let notification = NSUserNotification()
        notification.title = Copy("screenshot.notification.title")
        notification.informativeText = Copy("screenshot.notification.success", lastScreenshotLocation?.pathByAddingTildeIfPossible ?? "?")
        notification.soundName = nil
        notification.identifier = NotificationDelegate.Identifier.screenshotSuccess.rawValue
        NSUserNotificationCenter.default.deliver(notification)
    }

    private func showCopySuccessNotification() {
        let notification = NSUserNotification()
        notification.title = Copy("screenshot.notification.title")
        notification.informativeText = Copy("screenshot.notification.success.clipboard")
        notification.soundName = nil
        notification.identifier = NotificationDelegate.Identifier.copyScreenshotSuccess.rawValue
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
        NSSound(named: "shutter")?.play()
    }

    private func screenshotPressed() {
        guard let lastLocation = lastScreenshotLocation else { return }
        NSWorkspace.shared.activateFileViewerSelecting([lastLocation])
    }

    @discardableResult
    func showLocationPicker() -> URL? {

        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.title = Copy("screenshot.locationPicker.title")

        let result = openPanel.runModal()

        if result == .OK, let url = openPanel.url {
            do {
                let data = try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
                Persistence.screenshotBookmark.value = data
                screenshotLocationChangedHandler.send()
            } catch {
                LogError(error)
                return nil
            }
        }

        return openPanel.url
    }

    var screenshotDirectory: URL? {
        guard let bookmark = Persistence.screenshotBookmark.value else { return nil }
        do {
            var isStale: Bool = false
            let url = try URL(resolvingBookmarkData: bookmark, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale == true {
                LogError("Bookmark is stale!")
                return nil
            }
            return url
        } catch {
            LogError(error)
            return nil
        }
    }

}
