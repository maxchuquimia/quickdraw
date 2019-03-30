//
//  InfoView.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 30/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

class InfoView: NSVisualEffectView {

    private let mainStack: NSStackView = create {
        $0.spacing = 10
        $0.orientation = .vertical
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder decoder: NSCoder) { die() }

    private func setup() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.cornerRadius = 20

        material = .hudWindow
        blendingMode = .behindWindow

        addText()

        NSLayoutConstraint.activate(
            widthAnchor.constraint(equalToConstant: 500)
        )
    }

    private func addText() {

        add(centered: Text(copy: "info.title").font(.title).color(.lightText), customSpace: 30)
        add(shortcut: Copy("info.shortcut.numbers"), info: Copy("info.shortcut.numbers.info"))
        add(shortcut: Copy("info.shortcut.letters"), info: Copy("info.shortcut.letters.info"))
        add(shortcut: Copy("info.shortcut.slash"), info: Copy("info.shortcut.slash.info"))
        add(shortcut: Copy("info.shortcut.hide"), info: Copy("info.shortcut.hide.info"))
        add(shortcut: Copy("info.shortcut.screenshot"), info: Copy("info.shortcut.screenshot.info"))
        add(shortcut: Copy("info.shortcut.esc"), info: Copy("info.shortcut.esc.info"), customSpace: 30)
        add(centered: Text(copy: "info.footnote").font(.small).color(.lightText))

        addSubview(mainStack)
        NSLayoutConstraint.activate(
            mainStack.constraintsFillingSuperview(insets: .allEdges(20))
        )
    }

    private func add(centered text: Text, customSpace: CGFloat? = nil) {
        let label = NSTextField(label: text)
        label.alignment = .center
        mainStack.addArrangedSubview(label)

        if let space = customSpace {
            mainStack.setCustomSpacing(space, after: label)
        }
    }

    private func add(shortcut: String, info: String, customSpace: CGFloat? = nil) {

        let stack: NSStackView = create {
            $0.spacing = 0
            $0.alignment = .top
            $0.distribution = .fill
        }

        let shortcutLabel = NSTextField(label: Text(shortcut).font(.light).color(.lightText))
        stack.addArrangedSubview(shortcutLabel)
        shortcutLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true

        let infoLabel = NSTextField(label: Text(info).font(.regular).color(.lightText))
        stack.addArrangedSubview(infoLabel)
        infoLabel.widthAnchor.constraint(equalToConstant: 320).isActive = true

        mainStack.addArrangedSubview(stack)

        if let space = customSpace {
            mainStack.setCustomSpacing(space, after: stack)
        }
    }
}
