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

    var radioState: State = .normal {
        didSet { reloadStyle() }
    }

    init(item: Item, title: String = "") {
        self.representedItem = item
        super.init(frame: .zero)
        self.attributedTitle = Text(title).font(.boldButton).color(.black).attributedString
        isBordered = false
        setup()
        reloadStyle()
    }

    required init?(coder: NSCoder) { die() }

    func reloadStyle() {
        Log(self, radioState, highlighted: radioState != .normal)

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
