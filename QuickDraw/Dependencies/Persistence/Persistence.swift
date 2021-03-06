//
//  Persistence.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 9/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

enum Persistence {

    static var screenshotBookmark: Storable<Data> = "qd.screenshotBookmark"
    static var infoMessageHidden: Storable<Bool> = "qd.infoMessageHidden"
    static var lowerToolbarHidden: Storable<Bool> = "qd.lowerToolbarHidden"
    static var lastSelectedColorIndex: Storable<Int> = "qd.lastSelectedColorIndex"
    static var lastSelectedShapeIndex: Storable<Int> = "qd.lastSelectedShapeIndex"

}
