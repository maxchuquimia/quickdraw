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
    private let colorsRadioGroup = RadioButtonGroup(options: [
        ColorRadioButton(item: .systemRed, title: "1"),
        ColorRadioButton(item: .systemYellow, title: "2"),
        ColorRadioButton(item: .systemGreen, title: "3"),
        ColorRadioButton(item: .systemBlue, title: "4"),
        ColorRadioButton(item: .systemPurple, title: "5"),
    ])
    private let shapesRadioGroup = RadioButtonGroup<DrawingViewResponder.Shape, ShapeRadioButton>(options: [
        ShapeRadioButton(item: .line),
        ShapeRadioButton(item: .arrow),
        ShapeRadioButton(item: .rect),
        ShapeRadioButton(item: .circle),
    ])
    private let brush: InteractionDisabledView = create {
        $0.setFrameSize(NSSize(width: 6, height: 6))
        $0.wantsLayer = true
        $0.layer?.cornerRadius = $0.frame.size.height / 2.0
    }

    private let infoView: InfoView = create {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
        model.shapeKeyboardKeyHandler += weak(Function.keyboard(selectedShape:))
        model.slashKeyboardKeyHandler += weak(Function.keyboardPressedSlash)
        model.configureForScreenshotHandler += weak(Function.configure(forScreenshot:))
        model.isTracking += weak(Function.model(isTracking:))
        colorsRadioGroup.selectedItem += weak(Function.update(selectedColor:))
        shapesRadioGroup.selectedItem += weak(Function.update(selectedShape:))
        createLayout()

        becomeFirstResponder()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        NSTrackingArea.setup(in: self)

        guard let undoManager = window?.undoManager else { return }
        model.undoManager = undoManager
        model.view = self
    }

    private func createLayout() {
        addSubview(infoView)
        addSubview(brush)

        colorsRadioGroup.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorsRadioGroup)

        shapesRadioGroup.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shapesRadioGroup)

        NSLayoutConstraint.activate(
            infoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoView.centerYAnchor.constraint(equalTo: centerYAnchor),

            colorsRadioGroup.leftAnchor.constraint(equalTo: leftAnchor, constant: 30),
            colorsRadioGroup.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),

            shapesRadioGroup.leftAnchor.constraint(equalTo: colorsRadioGroup.rightAnchor, constant: 50),
            shapesRadioGroup.bottomAnchor.constraint(equalTo: colorsRadioGroup.bottomAnchor)
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
        updateBrush(for: event)
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        updateBrush(for: event)
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

// MARK: - Bindings
extension DrawingView {

    func redraw(renderables: [Renderable]) {
        needsDisplay = true
    }

    func model(isTracking: Bool) {
        brush.isHidden = isTracking
        needsDisplay = true

        if isTracking && !infoView.isHidden {
            infoView.isHidden = true
        }
    }

    func keyboardPressedSlash() {
        infoView.isHidden = !infoView.isHidden
    }

    func configure(forScreenshot isScreenshot: Bool) {
        colorsRadioGroup.isHidden = isScreenshot
        shapesRadioGroup.isHidden = isScreenshot
        brush.isHidden = isScreenshot
    }

    func keyboard(selectedColor index: Int) {
        colorsRadioGroup.select(item: index)
    }

    func keyboard(selectedShape index: Int) {
        shapesRadioGroup.select(item: index)
    }

    func update(selectedColor: NSColor) {
        model.selectedColor = selectedColor
        brush.layer?.backgroundColor = selectedColor.cgColor
        shapesRadioGroup.buttons.forEach({ $0.tintColor = selectedColor })
    }

    func update(selectedShape: DrawingViewResponder.Shape) {
        model.selectedShape = selectedShape
    }
}

// MARK: - Private
private extension DrawingView {

    func updateBrush(for event: NSEvent) {
        let location = event.locationInWindow.offset(x: -brush.frame.width / 2, y: -brush.frame.width / 2)
        brush.setFrameOrigin(location)
    }
}
