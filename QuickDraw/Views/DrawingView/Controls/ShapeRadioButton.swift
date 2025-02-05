//
//  ShapeRadioButton.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 28/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

final class ShapeRadioButton: BaseRadioButton<DrawingViewModel.Shape> {

    enum Metrics {
        static let imageInset = NSEdgeInsets.allEdges(8)
    }

    var modified = false {
        didSet { updateIcon() }
    }

    var tintColor: NSColor = .white {
        didSet { reloadStyle() }
    }

    private let imageView: NSImageView = create {
        $0.imageAlignment = .alignCenter
        $0.imageScaling = .scaleProportionallyDown
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    override func setup() {
        super.setup()

        addSubview(imageView)
        NSLayoutConstraint.activate(
            imageView.constraintsFillingSuperview(insets: Metrics.imageInset)
        )

        updateIcon()
    }

    override func styleNormal() {
        super.styleNormal()
        layer?.borderColor = tintColor.cgColor
        layer?.backgroundColor = NSColor.white.cgColor
    }

    override func styleSelected() {
        super.styleSelected()
        layer?.borderColor = tintColor.cgColor
        layer?.backgroundColor = tintColor.cgColor
    }

    func updateIcon() {
        if modified {
            switch representedItem {
            case .arrow: imageView.image = Image.Shape.arrowModified
            case .line: imageView.image = Image.Shape.lineModified
            case .rect: imageView.image = Image.Shape.rectangleModified
            case .circle: imageView.image = Image.Shape.circleModified
            }
        } else {
            switch representedItem {
            case .arrow: imageView.image = Image.Shape.arrow
            case .line: imageView.image = Image.Shape.line
            case .rect: imageView.image = Image.Shape.rectangle
            case .circle: imageView.image = Image.Shape.circle
            }
        }
    }

}
