//
//  ViewController.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class DrawingViewController: NSViewController, Watcher {

    private let model = DrawingViewModel()

    var canvas: DrawingView {
        return view as! DrawingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ScreenDaemon.shared.currentScreen += weak(Function.screenChanged(to:))

        canvas.colorsRadioGroup.selectedItem += weak(Function.update(selectedColor:))
        canvas.shapesRadioGroup.selectedItem += weak(Function.update(selectedShape:))
        canvas.keyEquivalentHandler.action = weak(Function.performKeyEquivalent)

        model.drawings += canvas.weak(DrawingView.redraw(renderables:))
        model.colorKeyboardKeyHandler += canvas.weak(DrawingView.keyboard(selectedColor:))
        model.shapeKeyboardKeyHandler += canvas.weak(DrawingView.keyboard(selectedShape:))
        model.slashKeyboardKeyHandler += canvas.weak(DrawingView.keyboardPressedSlash)
        model.isTracking += canvas.weak(DrawingView.model(isTracking:))
        Screenshotter.shared.configureForScreenshotHandler += canvas.weak(DrawingView.configure(forScreenshot:))

        model.view = canvas

        NSTrackingArea.setup(in: canvas)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard let undoManager = undoManager else { die() }
        model.undoManager = undoManager
    }

    func screenChanged(to screen: NSScreen?) {
        guard let screen = screen else { return }
        view.window?.setFrame(screen.visibleFrame, display: true)
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        model.mouseDown(with: event)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        model.mouseDragged(with: event)
        canvas.updateBrush(for: event)
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        canvas.updateBrush(for: event)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        model.mouseUp(with: event)
    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        model.keyDown(with: event)
    }

    override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
        model.flagsChanged(with: event)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return model.canHandle(key: event.keyCode)
    }
}

// MARK: - Bindings
private extension DrawingViewController {
    func update(selectedColor: NSColor) {
        model.selectedColor = selectedColor
    }

    func update(selectedShape: DrawingViewModel.Shape) {
        model.selectedShape = selectedShape
    }
}
