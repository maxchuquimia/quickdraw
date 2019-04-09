//
//  TextExtensions.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 30/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

extension NSTextField {

    convenience init(label: AttributedStringGenerator) {
        self.init(labelWithAttributedString: label.attributedString)
    }
}

extension NSTextView {

    convenience init(label: AttributedStringGenerator) {
        self.init()
        textStorage?.setAttributedString(label.attributedString)
        isEditable = false
        isSelectable = false
        backgroundColor = .clear

        linkTextAttributes = label.attributes
        linkTextAttributes?[.underlineStyle] = 1

    }
}

class LinkyTextView: NSTextView {

    let linkHandler: Handler<URL> = .init()

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        DispatchQueue.main.async {
            NSCursor.arrow.set()
        }
    }

    // Try to reproduce iOS behaviour when scrolling is disabled on a UITextView
    override var intrinsicContentSize: NSSize {
        guard let container = textContainer else { return super.intrinsicContentSize }
        layoutManager?.ensureLayout(for: container)
        return layoutManager?.usedRect(for: container).size ?? super.intrinsicContentSize
    }

    // Disable highlighting of text was done with `isSelectable = false`, but now links don't work
    // So, manually handle links
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)

        guard let container = textContainer else { return }
        guard let index = layoutManager?.characterIndex(for: point, in: container, fractionOfDistanceBetweenInsertionPoints: nil) else { return }

        guard let url = attributedString().attribute(.link, at: index, effectiveRange: nil) as? URL else { return }
        linkHandler.send(url)
    }
}
