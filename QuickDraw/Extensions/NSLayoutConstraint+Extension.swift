//
//  NSLayoutConstraint+Extension.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 14/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

extension NSView {

    func constraintsFillingSuperview(insets: NSEdgeInsets = NSEdgeInsetsZero) -> [NSLayoutConstraint] {
        guard let superview = self.superview else { die() }

        translatesAutoresizingMaskIntoConstraints = false

        return [
            superview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            superview.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left),
            superview.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets.right),
            superview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
        ]
    }
}

extension NSLayoutConstraint {

    static func activate(_ constraints: NSLayoutConstraint...) {
        NSLayoutConstraint.activate(constraints)
    }

    static func activate(_ constraints: [NSLayoutConstraint]...) {
        NSLayoutConstraint.activate(constraints.flatMap({ $0 }))
    }
}
