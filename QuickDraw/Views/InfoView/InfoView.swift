//
//  InfoView.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 30/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

final class InfoView: NSVisualEffectView, Watcher {

    enum Links: URL {
        typealias RawValue = URL
        case saveLocation = "qd://saveLocation"
        case github = "qd://github"
    }

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
        appearance = .init(named: .darkAqua)

        material = .hudWindow
        blendingMode = .behindWindow

        addText()

        NSLayoutConstraint.activate(
            widthAnchor.constraint(equalToConstant: 500)
        )
    }

    private func addText() {
        let footnote = Text(copy: "info.footnote.1").font(.small).color(.lightText) +
                       Text(copy: "info.footnote.2").font(.small).color(.lightText).link(Links.github.rawValue)

        add(centered: Text(copy: "info.title").font(.title).color(.lightText), customSpace: 30)
        add(shortcutStyle(Copy("info.shortcut.numbers")), descriptionStyle(Copy("info.shortcut.numbers.info")))
        add(shortcutStyle(Copy("info.shortcut.letters")), descriptionStyle(Copy("info.shortcut.letters.info")))
        add(shortcutStyle(Copy("info.shortcut.backspace")), descriptionStyle(Copy("info.shortcut.backspace.info")))
        add(shortcutStyle(Copy("info.shortcut.slash")), descriptionStyle(Copy("info.shortcut.slash.info")))
        add(shortcutStyle(Copy("info.shortcut.opt_slash")), descriptionStyle(Copy("info.shortcut.opt_slash.info")))
        add(shortcutStyle(Copy("info.shortcut.hide")), descriptionStyle(Copy("info.shortcut.hide.info")))
        add(shortcutStyle(Copy("info.shortcut.screenshot.clipboard")), descriptionStyle(Copy("info.shortcut.screenshot.clipboard.info")))
        let screenshotLabel = add(shortcutStyle(Copy("info.shortcut.screenshot")), screenshotDescription()).1
        add(shortcutStyle(Copy("info.shortcut.esc")), descriptionStyle(Copy("info.shortcut.esc.info")), customSpace: 30)
        add(centered: footnote)

        Screenshotter.shared.screenshotLocationChangedHandler.value(self) { [weak self] in
            guard let self = self else { return }
            screenshotLabel.textStorage?.setAttributedString(self.screenshotDescription().attributedString)
            screenshotLabel.invalidateIntrinsicContentSize()
        }

        addSubview(mainStack)
        NSLayoutConstraint.activate(
            mainStack.constraintsFillingSuperview(insets: .allEdges(20))
        )

        // This ensures the layout works for multi-linked screenshot descriptions
        DispatchQueue.main.async {
            screenshotLabel.invalidateIntrinsicContentSize()
        }
    }

    private func screenshotDescription() -> AttributedStringGenerator {
        let screenshotLocation = Screenshotter.shared.screenshotDirectory?.pathByAddingTildeIfPossible ?? Copy("info.shortcut.screenshot.info.select")
        let screenshotDescriptionPrefix = descriptionStyle(Copy("info.shortcut.screenshot.info", screenshotLocation))
        let finalString = screenshotDescriptionPrefix + linkStyle(screenshotLocation, Links.saveLocation.rawValue)
        Log("Screenshot URL updated:", finalString.attributedString.string)
        return finalString
    }

    private func add(centered text: AttributedStringGenerator, customSpace: CGFloat? = nil) {
        let label = LinkyTextView(label: text)
        label.linkHandler += weak(Function.handle(link:))
        label.alignment = .center
        mainStack.addArrangedSubview(label)

        // A little hack because LinkyTextView needs to calculate it's own content size
        label.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true

        if let space = customSpace {
            mainStack.setCustomSpacing(space, after: label)
        }
    }

    @discardableResult
    private func add(_ shortcut: AttributedStringGenerator, _ info: AttributedStringGenerator, customSpace: CGFloat? = nil) -> (NSTextField, LinkyTextView) {
        let stack: NSStackView = create {
            $0.spacing = 0
            $0.alignment = .top
            $0.distribution = .fill
        }

        let shortcutLabel = NSTextField(label: shortcut)
        stack.addArrangedSubview(shortcutLabel)
        shortcutLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true

        let infoLabel = LinkyTextView(label: info)
        infoLabel.linkHandler += weak(Function.handle(link:))
        stack.addArrangedSubview(infoLabel)
        infoLabel.widthAnchor.constraint(equalToConstant: 320).isActive = true

        mainStack.addArrangedSubview(stack)

        if let space = customSpace {
            mainStack.setCustomSpacing(space, after: stack)
        }

        return (shortcutLabel, infoLabel)
    }

    private func shortcutStyle(_ string: String) -> Text {
        Text(string).font(.light).color(.lightText)
    }

    private func descriptionStyle(_ string: String) -> Text {
        Text(string).font(.regular).color(.lightText)
    }

    private func linkStyle(_ string: String, _ link: URL) -> Text {
        Text(string).font(.regular).color(.lightText).link(link)
    }

    private func handle(link: URL) {
        guard let linkType = Links(rawValue: link) else { return }

        switch linkType {
        case .saveLocation: Screenshotter.shared.showLocationPicker()
        case .github: NSWorkspace.shared.open(URL(string: "https://github.com/Jugale/quickdraw")!)
        }
    }

}
