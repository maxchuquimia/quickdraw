//
//  ScreenDaemon.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 1/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

final class ScreenDaemon {

    private enum Constants {
        static let nativeScreenshotToolBundleIdentifier = "com.apple.screencaptureui"
    }

    static let shared = ScreenDaemon()

    let currentScreen: Watchable<NSScreen?> = .init(nil)
    let screenChanged: Handler<(old: NSScreen?, new: NSScreen?)> = .init()
    let nativeScreenshotToolVisible: Watchable<Bool> = .init(false)

    private var timer: Timer?
    private init() { }

    func startTimer() {
        stopTimer()
        // Every x seconds, check the mouse position
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        timerFired()
        Log("Started Timer")
    }

    func stopTimer() {
        guard timer?.isValid == true else { return }
        timer?.invalidate()
        Log("Stopped Timer")
    }

    @objc private func timerFired() {
        guard NSApplication.shared.isActive else { return }

        let mouseScreen = getScreenWithMouse()

        if currentScreen.value != mouseScreen {
            screenChanged.send((old: currentScreen.value, new: mouseScreen))
            currentScreen.value = mouseScreen
        }

        // The native screenshot tool takes the mouse away from us, so it can only be detected by polling
        let isScreenshotToolVisible = !NSRunningApplication.runningApplications(withBundleIdentifier: Constants.nativeScreenshotToolBundleIdentifier).isEmpty

        if nativeScreenshotToolVisible.value != isScreenshotToolVisible {
            nativeScreenshotToolVisible.value = isScreenshotToolVisible
        }
    }

    private func getScreenWithMouse() -> NSScreen? {
        NSScreen.screens.first { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) }
    }

}
