//
//  DrawingView.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class DrawingView: NSView, Watcher {

    private enum Metrics {
        static let defaultSpacing: CGFloat = 30.0
        static let defaultBottomSpacing: CGFloat = Metrics.defaultSpacing + Metrics.menuBarHeight
        static let menuBarHeight = NSApplication.shared.mainMenu?.menuBarHeight ?? 0.0
    }

    let keyEquivalentHandler: Delegate<NSEvent, Bool> = .init(false)

    let colorsRadioGroup = RadioButtonGroup(options: [
        ColorRadioButton(item: .systemRed, title: "1"),
        ColorRadioButton(item: .systemYellow, title: "2"),
        ColorRadioButton(item: .systemGreen, title: "3"),
        ColorRadioButton(item: .systemBlue, title: "4"),
        ColorRadioButton(item: .systemPurple, title: "5"),
    ])

    let shapesRadioGroup = RadioButtonGroup<DrawingViewModel.Shape, ShapeRadioButton>(options: [
        ShapeRadioButton(item: .line),
        ShapeRadioButton(item: .arrow),
        ShapeRadioButton(item: .rect),
        ShapeRadioButton(item: .circle),
    ])

    private var colorsRadioGroupBottom: NSLayoutConstraint?
    
    var bottomSpacing: CGFloat = -Metrics.defaultBottomSpacing {
        didSet {
            colorsRadioGroupBottom?.constant = -bottomSpacing - Metrics.defaultBottomSpacing
        }
    }

    private let brush: InteractionDisabledView = create {
        $0.setFrameSize(NSSize(width: 6, height: 6))
        $0.wantsLayer = true
        $0.layer?.cornerRadius = $0.frame.size.height / 2.0
    }

    private let infoView: InfoView = create {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private var drawings: [Renderable] = []

    override var mouseDownCanMoveWindow: Bool { return false }
    override var acceptsFirstResponder: Bool { return true }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        colorsRadioGroup.selectedItem += weak(Function.update(selectedColor:))
        createLayout()

        if Persistence.infoMessageHidden.value == true {
            infoView.isHidden = true
        }
    }

    private func createLayout() {
        addSubview(infoView)
        addSubview(brush)

        colorsRadioGroup.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorsRadioGroup)

        shapesRadioGroup.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shapesRadioGroup)

        colorsRadioGroupBottom = colorsRadioGroup.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomSpacing)

        NSLayoutConstraint.activate(
            infoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoView.centerYAnchor.constraint(equalTo: centerYAnchor),

            colorsRadioGroup.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.defaultSpacing),
            colorsRadioGroupBottom!,

            shapesRadioGroup.leftAnchor.constraint(equalTo: colorsRadioGroup.rightAnchor, constant: 50),
            shapesRadioGroup.bottomAnchor.constraint(equalTo: colorsRadioGroup.bottomAnchor)
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawings.forEach { $0.render() }
    }

    // Stop the bell sound from playing on known key presses that the system doesn't know we will handle
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return keyEquivalentHandler.execute(event)
    }
}

// MARK: - Bindings
extension DrawingView {

    func redraw(renderables: [Renderable]) {
        drawings = renderables
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
        Persistence.infoMessageHidden.value = infoView.isHidden
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
        brush.layer?.backgroundColor = selectedColor.cgColor
        shapesRadioGroup.buttons.forEach({ $0.tintColor = selectedColor })
    }

    func set(modified: Bool) {
        shapesRadioGroup.buttons.forEach({ $0.modified = modified })
    }
}

// MARK: - Public
extension DrawingView {

    func updateBrush(for event: NSEvent) {
        let location = event.locationInWindow.offset(x: -brush.frame.width / 2, y: -brush.frame.width / 2)
        brush.setFrameOrigin(location)
    }
}
