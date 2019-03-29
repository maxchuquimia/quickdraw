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
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leftAnchor.constraint(equalTo: superview.leftAnchor, constant: insets.left),
            rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom),
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
