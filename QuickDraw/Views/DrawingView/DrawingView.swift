//
//  DrawingView.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class DrawingView: NSView, Watcher {

    private let model = DrawingViewResponder()
    private let colorsStack = RadioButtonGroup(options: [
        PaletteColourView(item: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), debugName: "Red"),
        PaletteColourView(item: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), debugName: "Yellow"),
        PaletteColourView(item: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), debugName: "Green"),
        PaletteColourView(item: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), debugName: "Blue"),
        PaletteColourView(item: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), debugName: "Purple"),
    ])
    private let brush: NSView = create {
        $0.setFrameSize(NSSize(width: 6, height: 6))
        $0.wantsLayer = true
        $0.layer?.cornerRadius = $0.frame.size.height / 2.0
    }

    override var mouseDownCanMoveWindow: Bool { return false }
    override var acceptsFirstResponder: Bool { return true }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        model.drawings += weak(Function.redraw(renderables:))
        model.colorKeyboardKeyHandler += weak(Function.keyboard(selectedColor:))
        colorsStack.selectedItem += weak(Function.update(selectedColor:))
        createLayout()

        becomeFirstResponder()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        NSTrackingArea.setup(in: self)

        guard let undoManager = window?.undoManager else { return }
        model.undoManager = undoManager
    }

    private func createLayout() {
        addSubview(brush)

        colorsStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorsStack)

        NSLayoutConstraint.activate(
            colorsStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 30),
            colorsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        model.drawings.value.forEach { $0.render() }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        model.mouseDown(with: event, in: self)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        model.mouseDragged(with: event, in: self)
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)

        let location = event.locationInWindow.offset(x: -brush.frame.width / 2, y: -brush.frame.width / 2)
        brush.setFrameOrigin(location)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        model.mouseUp(with: event)
    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        model.keyDown(with: event)
    }

    // Stop the bell sound from playing on known key presses that the system doesn't know we will handle
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return model.canHandle(key: event.keyCode)
    }
}

extension DrawingView {

    func redraw(renderables: [Renderable]) {
        needsDisplay = true
    }

    func keyboard(selectedColor index: Int) {
        colorsStack.select(item: index)
    }

    func update(selectedColor: NSColor) {
        model.selectedColor = selectedColor
    }
}
