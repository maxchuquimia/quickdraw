//
//  DrawingViewModel.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class DrawingViewResponder {

    enum Shape {
        case arrow, rect, circle
    }

    let drawings: Watchable<[Renderable]> = .init([])
//    let colors: Watchable<[PaletteColourView]> = .init([])
    let colorKeyboardKeyHandler: Handler<Int> = .init()
    var selectedColor: NSColor = .white
    let selectedShape: Watchable<Shape> = .init(.arrow)
    var undoManager: UndoManager

    private var isTracking = false

    init(undoManager: UndoManager = .init()) {
        self.undoManager = undoManager
    }

    func mouseDown(with event: NSEvent, in view: NSView) {
        isTracking = true
        let location = view.convert(event.locationInWindow, from: nil)

        createNewPath(startingAt: location)
    }

    func mouseDragged(with event: NSEvent, in view: NSView) {
        guard isTracking else { return }
        let location = view.convert(event.locationInWindow, from: nil)

        // Add a waypoint to the new path
        drawings.value.last?.mouseMoved(to: location)
        drawings.update()
    }

    func mouseUp(with event: NSEvent) {
        isTracking = false
    }

    func keyDown(with event: NSEvent) {
        guard !event.isARepeat else { return }

        switch Int(event.keyCode) {
        case KeyCodes.color1: colorPressed(0)
        case KeyCodes.color2: colorPressed(1)
        case KeyCodes.color3: colorPressed(2)
        case KeyCodes.color4: colorPressed(3)
        case KeyCodes.color5: colorPressed(4)
        case KeyCodes.escape: escapePressed()
        default: break
        }
    }

    func canHandle(key code: UInt16) -> Bool {
        return KeyCodes.allCases.contains(Int(code))
    }
}

// MARK: - Private
private extension DrawingViewResponder {

    func colorPressed(_ index: Int) {
        colorKeyboardKeyHandler.send(index)
    }

    func escapePressed() {

        if drawings.value.isEmpty {
            // Hide the window
            NSApplication.shared.hide(nil)
            clearUndoHistory()
        } else {
            // Clear the drawings
            clearDrawings()
        }
    }

    func createNewPath(startingAt point: CGPoint) {

        let shape: Renderable

        switch selectedShape.value {
        case .arrow:
            shape = RenderableLine(origin: point, isArrow: true)
            shape.fillColor = selectedColor
            shape.strokeColor = selectedColor
        case .rect:
            shape = RenderableRect(origin: point)
            shape.strokeColor = selectedColor
            shape.fillColor = selectedColor.withAlphaComponent(0.2)
        case .circle:
            shape = RenderableCircle(center: point)
            shape.strokeColor = selectedColor
            shape.fillColor = nil
        }

        append(drawing: shape)
    }
}

// MARK: - Undo / Redo
private extension DrawingViewResponder {

    func append(drawing: Renderable) {
        drawings.value.append(drawing)

        undoManager.registerUndo(withTarget: self) { (self) in
            self.remove(drawing: drawing)
        }

        undoManager.setActionName(Copy("drawing.undo.drawAction", drawing.actionName))
    }

    func remove(drawing: Renderable) {
        drawings.value.removeAll(where: { $0 === drawing })

        undoManager.registerUndo(withTarget: self) { (self) in
            self.append(drawing: drawing)
        }

        undoManager.setActionName(Copy("drawing.undo.drawAction", drawing.actionName))
    }

    func clearDrawings() {
        let backup = drawings.value
        drawings.value = []

        undoManager.registerUndo(withTarget: self) { (self) in
            self.restore(drawings: backup)
        }

        undoManager.setActionName(Copy("drawing.undo.clearAction"))
    }

    func restore(drawings: [Renderable]) {
        self.drawings.value = drawings

        undoManager.registerUndo(withTarget: self) { (self) in
            self.clearDrawings()
        }

        undoManager.setActionName(Copy("drawing.undo.clearAction"))
    }

    func clearUndoHistory() {
        undoManager.removeAllActions(withTarget: self)
    }
}
