//
//  AppDelegate.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let notificationDelegate = NotificationDelegate()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSUserNotificationCenter.default.delegate = notificationDelegate
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        ScreenDaemon.shared.startTimer()
    }

    func applicationDidResignActive(_ notification: Notification) {
        ScreenDaemon.shared.stopTimer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func saveButtonPressed(_ sender: NSMenuItem) {
        NotificationCenter.saveButtonPressed.send()
    }

    // For some reason this doesn't work with the keyboard shortcut... responder chain issue?
    @IBAction func copyButtonPressed(_ sender: NSMenuItem) {
        NotificationCenter.copyButtonPressed.send()
    }

    @IBAction func helpPressed(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://github.com/Jugale/quickdraw/issues")!)
    }
}

