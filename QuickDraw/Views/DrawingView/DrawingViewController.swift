//
//  ViewController.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class DrawingViewController: NSViewController, Watcher {

    override func viewDidLoad() {
        super.viewDidLoad()

        ScreenDaemon.shared.currentScreen += weak(Function.screenChanged(to:))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    func screenChanged(to screen: NSScreen?) {
        guard let screen = screen else { return }
        view.window?.setFrame(screen.visibleFrame, display: true)
    }
}
