//
//  DrawingViewModel.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

final class DrawingViewModel: Watcher {

    enum Shape {
        case arrow, line, rect, circle, text
    }

    let drawings: Watchable<[Renderable]> = .init([])
    let colorKeyboardKeyHandler: Handler<Int> = .init()
    let shapeKeyboardKeyHandler: Handler<Int> = .init()
    let slashKeyboardKeyHandler: Handler<Void> = .init()
    let optionSlashKeyboardKeyHandler: Handler<Void> = .init()
    let showShortcutsNotificationHandler: Handler<Void> = .init()
    let isTracking: Watchable<Bool> = .init(false)
    let enableModification: Watchable<Bool> = .init(false)
    var enableTranslation: Bool = false
    var selectedColor: NSColor = .white
    var selectedShape: Shape = .arrow
    var currentMouseLocation: CGPoint = .zero
    var undoManager: UndoManager
    private(set) var editingText: RenderableText?
    private var cursorTimer: Timer?
    private var isCapturing = false
    private let cache: Cache<NSScreen, [Renderable]>
    weak var view: DrawingView?

    init(undoManager: UndoManager = .init(), cache: Cache<NSScreen, [Renderable]> = .init()) {
        self.undoManager = undoManager
        self.cache = cache

        NotificationCenter.saveButtonPressed += weak(Function.screenshotRequested)
        NotificationCenter.copyButtonPressed += weak(Function.copyScreenshotRequested)
        NotificationCenter.showShortcutsButtonPressed += weak(Function.showShortcutsRequested)
        ScreenDaemon.shared.screenChanged += weak(Function.screenChanged(screens:))
        ScreenDaemon.shared.nativeScreenshotToolVisible += weak(Function.hideCursor(while:))
        Screenshotter.shared.configureForScreenshotHandler += weak(Function.hideCursor(while:))
    }

    func mouseDown(with event: NSEvent) {
        guard let view = view else { return }
        endEditingText()
        currentMouseLocation = view.convert(event.locationInWindow, from: nil)
        isTracking.value = true
        createNewPath(startingAt: currentMouseLocation)
    }

    func mouseDragged(with event: NSEvent) {
        guard let view = view else { return }
        let previousLocation = currentMouseLocation
        currentMouseLocation = view.convert(event.locationInWindow, from: nil)
        guard isTracking.value else { return }

        if enableTranslation {
            let delta = CGPoint(x: currentMouseLocation.x - previousLocation.x, y: currentMouseLocation.y - previousLocation.y)
            drawings.value.last?.translate(by: delta)
        } else {
            // Add a waypoint to the new path
            drawings.value.last?.mouseMoved(to: currentMouseLocation)
        }

        updateLastDrawingModifiedIfTracking()
        drawings.update()
    }

    func mouseUp(with event: NSEvent) {
        isTracking.value = false

        if let text = drawings.value.last as? RenderableText {
            beginEditing(text: text)
            return
        }

        // If the last item was tiny, just undo drawing it.
        // This stops random clicks from appearing in the Undo stack
        if let count = drawings.value.last?.path.elementCount, count < 2 {
            undoManager.undo()
        }
    }

    func mouseMoved(with event: NSEvent) {
        guard let view = view else { return }
        currentMouseLocation = view.convert(event.locationInWindow, from: nil)
    }

    func keyDown(with event: NSEvent) {
        if let text = editingText {
            switch Int(event.keyCode) {
            case KeyCodes.escape: endEditingText()
            case KeyCodes.backspace: text.deleteBackwards()
            default: text.insert(event.characters ?? "")
            }

            drawings.update()
            return
        }

        guard !event.isARepeat else { return }

        switch Int(event.keyCode) {
        case KeyCodes.color1: colorPressed(0)
        case KeyCodes.color2: colorPressed(1)
        case KeyCodes.color3: colorPressed(2)
        case KeyCodes.color4: colorPressed(3)
        case KeyCodes.color5: colorPressed(4)
        case KeyCodes.charL: shapePressed(0)
        case KeyCodes.charA: shapePressed(1)
        case KeyCodes.charR: shapePressed(2)
        case KeyCodes.charC: shapePressed(3)
        case KeyCodes.charT: shapePressed(4)
        case KeyCodes.escape: escapePressed()
        case KeyCodes.backspace: backspacePressed()
        case KeyCodes.space: spacePressed(isPressed: true)
        case KeyCodes.slash where event.modifierFlags.contains(.option): optionSlashKeyboardKeyHandler.send(())
        case KeyCodes.slash: slashKeyboardKeyHandler.send(())
        default: break
        }
    }

    func keyUp(with event: NSEvent) {
        switch Int(event.keyCode) {
        case KeyCodes.space: spacePressed(isPressed: false)
        default: break
        }
    }

    func flagsChanged(with event: NSEvent) {
        enableModification.value = event.modifierFlags.contains(.shift)
        let didUpdate = updateLastDrawingModifiedIfTracking()

        if didUpdate {
            drawings.update()
        }
    }

    @discardableResult
    func updateLastDrawingModifiedIfTracking() -> Bool {
        guard isTracking.value else { return false }
        drawings.value.last?.isModified = enableModification.value
        return true
    }

    func canHandle(key event: NSEvent) -> Bool {
        guard !event.modifierFlags.contains(.command) else { return false }
        return editingText != nil || KeyCodes.allCases.contains(Int(event.keyCode))
    }

    func prepare() {
        // Restore the state of the app to last launch
        if let oldValue = Persistence.lastSelectedColorIndex.value {
            colorPressed(oldValue)
        }

        if let oldValue = Persistence.lastSelectedShapeIndex.value {
            shapePressed(oldValue)
        }
    }

}

// MARK: - Private
private extension DrawingViewModel {

    func colorPressed(_ index: Int) {
        Persistence.lastSelectedColorIndex.value = index
        colorKeyboardKeyHandler.send(index)
    }

    func shapePressed(_ index: Int) {
        Persistence.lastSelectedShapeIndex.value = index
        shapeKeyboardKeyHandler.send(index)
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

    func backspacePressed() {
        for drawing in drawings.value {
            guard drawing.intersects(point: currentMouseLocation) else { continue }
            remove(drawing: drawing)
        }
    }

    func spacePressed(isPressed: Bool) {
        enableTranslation = isPressed
    }

    func beginEditing(text: RenderableText) {
        editingText = text
        text.isDrawing = false
        text.isEditing = true

        cursorTimer?.invalidate()
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, !self.isCapturing else { return }
            text.isCursorVisible.toggle()
            self.drawings.update()
        }

        drawings.update()
    }

    func endEditingText() {
        guard let text = editingText else { return }
        stopEditingText()

        // Nothing was typed, so just undo drawing it
        if text.string.isEmpty {
            undoManager.undo()
        }

        drawings.update()
    }

    func stopEditingText() {
        editingText?.isEditing = false
        editingText = nil
        cursorTimer?.invalidate()
        cursorTimer = nil
    }

    func hideCursor(while isCapturing: Bool) {
        self.isCapturing = isCapturing
        editingText?.isCursorVisible = !isCapturing
        drawings.update()
    }

    func createNewPath(startingAt point: CGPoint) {
        let shape: Renderable

        switch selectedShape {
        case .line:
            shape = RenderableLine(origin: point, isArrow: false)
            shape.fillColor = selectedColor
            shape.strokeColor = selectedColor
        case .arrow:
            shape = RenderableLine(origin: point, isArrow: true)
            shape.fillColor = selectedColor
            shape.strokeColor = selectedColor
        case .rect:
            shape = RenderableRect(origin: point)
            shape.strokeColor = selectedColor
            shape.fillColor = selectedColor
        case .circle:
            shape = RenderableCircle(center: point)
            shape.strokeColor = selectedColor
            shape.fillColor = selectedColor
        case .text:
            shape = RenderableText(origin: point)
            shape.strokeColor = selectedColor
        }

        append(drawing: shape)
    }

}

// Mark: - Bindings
private extension DrawingViewModel  {

    func screenshotRequested() {
        guard let screen = view?.window?.screen else { return }
        Screenshotter.shared.capture(screen: screen)
    }

    func copyScreenshotRequested() {
        guard let screen = view?.window?.screen else { return }
        Screenshotter.shared.captureToClipboard(screen: screen)
    }

    func showShortcutsRequested() {
        showShortcutsNotificationHandler.send()
    }

    func screenChanged(screens: (old: NSScreen?, new: NSScreen?)) {
        if let screen = screens.old {
            cache[screen] = drawings.value
        }

        if let screen = screens.new {
            drawings.value = cache[screen] ?? []

            // At this stage we kind of shot ourselves in the foot by using just one window
            // The undo history gets confused when we swap out the drawing array when moving between screens
            // For now, just clear it.
            clearUndoHistory()
        }
    }

}

// MARK: - Drawing Actions & Undo / Redo
private extension DrawingViewModel {

    func append(drawing: Renderable) {
        drawings.value.append(drawing)

        undoManager.registerUndo(withTarget: self) { (self) in
            self.remove(drawing: drawing)
        }

        undoManager.setActionName(Copy("drawing.undo.drawAction", drawing.actionName, screenName))
    }

    func remove(drawing: Renderable) {
        if drawing === editingText {
            stopEditingText()
        }

        drawings.value.removeAll(where: { $0 === drawing })

        undoManager.registerUndo(withTarget: self) { (self) in
            self.append(drawing: drawing)
        }

        undoManager.setActionName(Copy("drawing.undo.drawAction", drawing.actionName, screenName))
    }

    func clearDrawings() {
        let backup = drawings.value
        drawings.value = []

        undoManager.registerUndo(withTarget: self) { (self) in
            self.restore(drawings: backup)
        }

        undoManager.setActionName(Copy("drawing.undo.clearAction", screenName))
    }

    func restore(drawings: [Renderable]) {
        self.drawings.value = drawings

        undoManager.registerUndo(withTarget: self) { (self) in
            self.clearDrawings()
        }

        undoManager.setActionName(Copy("drawing.undo.clearAction", screenName))
    }

    func clearUndoHistory() {
        undoManager.removeAllActions(withTarget: self)
    }

    var screenName: String {
        view?.window?.screen?.displayName ?? Copy("error.unknownScreenName")
    }

}
