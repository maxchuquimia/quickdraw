//
//  NSDateFormatter+Extension.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 31/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

private let dateFormatter = DateFormatter()

extension Date {

    enum Format: String {
        case screenshot = "yyyy-MM-dd 'at' hh.mm.ss a"
    }

    static func from(string: String?, format: Format) -> Date? {
        guard let string = string else { return nil }
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: string)
    }

    func `as`(_ format: Format) -> String {
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }
}

