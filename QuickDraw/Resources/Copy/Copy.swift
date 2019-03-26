//
//  Copy.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 12/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

func Copy(_ key: String) -> String {
    return NSLocalizedString(key, tableName: "Copy", bundle: Bundle.main, comment: key)
}

func Copy(_ key: String, _ value: String) -> String {
    return NSLocalizedString(key, tableName: "Copy", bundle: Bundle.main, value: value, comment: key)
}
