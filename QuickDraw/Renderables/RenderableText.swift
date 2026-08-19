//
//  RenderableText.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 19/8/26.
//  Copyright © 2026 Max Chuquimia. All rights reserved.
//

import Cocoa

final class RenderableText: Renderable {

    enum Metrics {
        static let minimumHeight = 16.f
        static let heightStep = 4.f
        /// The gap between the text and the rails, or the edges of the background, drawn around it
        static let boxPadding = 4.f
        // A thin space that becomes the blinking cursor by giving it a background colour
        static let cursor = "\u{2009}"
    }

    private var origin: CGPoint
    private var rect: NSRect
    private(set) var string = ""
    var isDrawing = true
    var isEditing = false
    var isCursorVisible = true

    override var actionName: String {
        Copy("renderable.type.text")
    }

    /// Text always draws above every other shape, so shapes can be drawn behind it as a background
    override var zIndex: Int { 1 }

    required init(origin: CGPoint) {
        self.origin = origin
        self.rect = NSRect(origin: origin, size: .zero)
        super.init(path: NSBezierPath())
    }

    override func mouseMoved(to point: CGPoint) {
        super.mouseMoved(to: point)
        rect = NSRect.from(start: origin, diagonallyOpposite: point)
    }

    override func translate(by distance: CGPoint) {
        super.translate(by: distance)
        origin.x += distance.x
        origin.y += distance.y
        rect = rect.offsetBy(dx: distance.x, dy: distance.y)
    }

    override func render() {
        super.render()

        if isModified {
            // Shift fills a rounded rectangle behind the text, which stays once editing has finished
            strokeColor?.setFill()
            let background = NSBezierPath(roundedRect: backgroundRect, xRadius: cornerRadius, yRadius: cornerRadius)
            background.fill()
        } else if let boxRect {
            // Show the size of the text that is about to be typed, or is being typed
            strokeColor?.setStroke()
            let box = NSBezierPath.verticalRails(around: boxRect)
            box.lineWidth = 1
            box.stroke()
        }

        displayedString.draw(with: textRect, options: [.usesLineFragmentOrigin])
    }

    override func intersects(point: CGPoint) -> Bool {
        isModified ? backgroundRect.contains(point) : textRect.contains(point)
    }

    func insert(_ characters: String) {
        guard let scalar = characters.unicodeScalars.first else { return }

        if scalar == "\r" {
            string += "\n"
        } else if !CharacterSet.controlCharacters.contains(scalar) {
            string += characters
        }
    }

    func deleteBackwards() {
        guard !string.isEmpty else { return }
        string.removeLast()
    }

}

// MARK: - Private
private extension NSColor {

    /// `true` if black text reads better on top of the receiver than white does
    var isLight: Bool {
        guard let color = usingColorSpace(.sRGB) else { return false }
        // Rec. 709 luma, which weights the components by how bright the eye perceives them to be
        let luma = 0.2126 * color.redComponent + 0.7152 * color.greenComponent + 0.0722 * color.blueComponent
        return luma > 0.5
    }

}

private extension NSBezierPath {

    /// Just the left and right edges of a box - the width is fixed, but the text is free to grow downwards
    static func verticalRails(around rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: NSPoint(x: rect.minX, y: rect.minY))
        path.line(to: NSPoint(x: rect.minX, y: rect.maxY))
        path.move(to: NSPoint(x: rect.maxX, y: rect.minY))
        path.line(to: NSPoint(x: rect.maxX, y: rect.maxY))
        return path
    }

}

private extension RenderableText {

    /// The height that was drawn, rounded to a multiple of 4
    var lineHeight: CGFloat {
        max(Metrics.minimumHeight, (rect.height / Metrics.heightStep).rounded() * Metrics.heightStep)
    }

    /// A font whose ascenders and descenders fit exactly into `lineHeight`
    var font: NSFont {
        let reference = NSFont.systemFont(ofSize: 100)
        return .systemFont(ofSize: lineHeight * 100 / (reference.ascender - reference.descender))
    }

    /// Text wraps at the right hand side of the drawn rectangle, but never narrower than the placeholder
    var wrappingWidth: CGFloat {
        max(rect.width, placeholder.size().width)
    }

    /// On a background the text has to contrast with it, otherwise it is drawn in the selected colour
    var textColor: NSColor {
        let color = strokeColor ?? NSColor.white
        return isModified ? (color.isLight ? .black : .white) : color
    }

    var attributes: [NSAttributedString.Key: Any] {
        // Centred text looks better on a background, where the edges of the block are visible
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = isModified ? .center : .left

        var result: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle,
        ]

        // A shadow lifts the text off the screen behind it, but is just noise on top of a background
        if !isModified {
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.4)
            shadow.shadowOffset = NSSize(width: 0, height: -2)
            shadow.shadowBlurRadius = 6
            result[.shadow] = shadow
        }

        return result
    }

    var attributedString: NSAttributedString {
        let result = NSMutableAttributedString(string: string, attributes: attributes)

        if isEditing {
            var cursorAttributes = attributes
            cursorAttributes[.backgroundColor] = isCursorVisible ? textColor : NSColor.clear
            result.append(NSAttributedString(string: Metrics.cursor, attributes: cursorAttributes))
        }

        return result
    }

    var placeholder: NSAttributedString {
        NSAttributedString(string: Copy("renderable.text.placeholder", "\(Int(lineHeight))"), attributes: attributes)
    }

    /// A click doesn't drag out a size, so there is nothing to show the user
    var isShowingPlaceholder: Bool {
        isDrawing && rect.size != .zero
    }

    /// The drawn rectangle, grown to always enclose the text as it wraps and flows below it. This
    /// also gives the box the same minimum size while dragging as it has once typing begins
    var enclosingRect: NSRect {
        rect.union(textRect)
    }

    /// The box drawn around the text while it is being sized or edited, `nil` once finished
    var boxRect: NSRect? {
        guard isShowingPlaceholder || isEditing else { return nil }
        return enclosingRect.insetBy(dx: -Metrics.boxPadding, dy: 0)
    }

    /// The background filled behind the text when Shift was held, padded on every side
    var backgroundRect: NSRect {
        enclosingRect.insetBy(dx: -Metrics.boxPadding, dy: -Metrics.boxPadding)
    }

    /// Corners scale with the text, so they stay proportional at every font size
    var cornerRadius: CGFloat {
        max(Metrics.boxPadding, lineHeight / 4)
    }

    var displayedString: NSAttributedString {
        isShowingPlaceholder ? placeholder : attributedString
    }

    /// The text starts at the top left of the drawn rectangle and is free to flow below it
    var textRect: NSRect {
        // Typed text wraps at the right hand side of the drawn rectangle, and so does the placeholder
        // when it is centred - it needs the full width to be centred within. Otherwise the placeholder
        // is laid out at its natural width, and never wrapped
        let usesFullWidth = !isShowingPlaceholder || isModified
        let layoutWidth = usesFullWidth ? wrappingWidth : .greatestFiniteMagnitude
        let size = NSSize(width: layoutWidth, height: .greatestFiniteMagnitude)
        let bounds = displayedString.boundingRect(with: size, options: [.usesLineFragmentOrigin])
        return NSRect(x: rect.minX, y: rect.maxY - bounds.height, width: usesFullWidth ? wrappingWidth : bounds.width, height: bounds.height)
    }

}
