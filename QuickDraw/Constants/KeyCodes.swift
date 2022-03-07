//
//  KeyCodes.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 5/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation
import Carbon

enum KeyCodes {

    static let color1 = kVK_ANSI_1
    static let color2 = kVK_ANSI_2
    static let color3 = kVK_ANSI_3
    static let color4 = kVK_ANSI_4
    static let color5 = kVK_ANSI_5

    static let escape = kVK_Escape
    static let slash = kVK_ANSI_Slash
    static let backspace = kVK_Delete // The key above the backslash key

    static let charL = kVK_ANSI_L
    static let charA = kVK_ANSI_A
    static let charR = kVK_ANSI_R
    static let charC = kVK_ANSI_C

//    case line = "l"
//    case arrow = "a"
//    case rectangle = "r"
//    case circle = "c"

    static let allCases: [Int] = [
        KeyCodes.color1,
        KeyCodes.color2,
        KeyCodes.color3,
        KeyCodes.color4,
        KeyCodes.color5,
        KeyCodes.escape,
        KeyCodes.slash,
        KeyCodes.backspace,
        KeyCodes.charL,
        KeyCodes.charA,
        KeyCodes.charR,
        KeyCodes.charC,
    ]

}
