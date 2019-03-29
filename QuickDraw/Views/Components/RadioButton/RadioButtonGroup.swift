//
//  ButtonGroup.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 14/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class RadioButtonGroup<Item, Button>: NSView where Button: RadioButton<Item> {

    let selectedItem: Watchable<Item>

    private let stack: NSStackView = create {
        $0.orientation = .horizontal
        $0.spacing = 15
    }

    let buttons: [Button]

    init(options: [Button]) {
        guard !options.isEmpty else { die() }

        self.buttons = options
        self.selectedItem = .init(options[0].representedItem)

        super.init(frame: .zero)

        options[0].radioState = .selected
        setup()
    }

    required init?(coder decoder: NSCoder) { die() }

    private func setup() {

        buttons.forEach({
            $0.target = self
            $0.action = #selector(pressed(button:))
            stack.addArrangedSubview($0)
        })

        addSubview(stack)

        NSLayoutConstraint.activate(
            stack.constraintsFillingSuperview()
        )
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        NSTrackingArea.setup(in: self)
    }

    func select(item index: Int) {
        pressed(button: buttons[index])
    }

    @objc private func pressed(button: NSControl) {
        let button = button as! Button // Cannot be used in argument due to @objc

        buttons.forEach({
            if $0 == button {
                $0.radioState = .selected
                selectedItem.value = button.representedItem
            } else {
                $0.radioState = .normal
            }
        })
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        calculateStyles(location: event.locationInWindow)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        calculateStyles(location: event.locationInWindow)
    }

    private func calculateStyles(location: CGPoint) {

        let localCoordinateLocation = convert(location, from: nil)

        buttons.forEach({
            guard $0.radioState != .selected else { return }

            if $0.frame.contains(localCoordinateLocation) {
                $0.radioState = .hover
            } else {
                $0.radioState = .normal
            }
        })
    }
}
