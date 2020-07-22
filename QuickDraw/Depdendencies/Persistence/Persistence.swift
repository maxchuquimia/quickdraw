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

}
