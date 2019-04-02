//
//  ScreenDaemon.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 1/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class ScreenDaemon {

    static let shared = ScreenDaemon()

    let currentScreen: Watchable<NSScreen?> = .init(nil)

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
            currentScreen.value = mouseScreen
        }
    }

    private func getScreenWithMouse() -> NSScreen? {
        return NSScreen.screens.first { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) }
    }
}
