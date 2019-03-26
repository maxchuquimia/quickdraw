//
//  Button.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 25/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class RadioButton<Item>: NSButton {

    enum State {
        case normal, hover, selected
    }

    let representedItem: Item
    let debugName: String

    var radioState: State = .normal {
        didSet { reloadStyle() }
    }

    init(item: Item, debugName: String) {
        self.representedItem = item
        self.debugName = debugName
        super.init(frame: .zero)
        isBordered = false
        stringValue = " "
        setup()
        reloadStyle()
    }

    required init?(coder: NSCoder) { die() }

    private func reloadStyle() {
        Log(debugName, radioState, highlighted: radioState != .normal)

        switch radioState {
        case .normal: styleNormal()
        case .hover: styleHover()
        case .selected: styleSelected()
        }
    }

    func setup() { die() }

    func styleNormal() { die() }

    func styleHover() { die() }

    func styleSelected() { die() }
}
