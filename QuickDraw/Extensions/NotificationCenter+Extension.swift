//
//  NotificationCenter+Extension.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 31/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

extension NotificationCenter {

    // These can act like strongly-typed NSNotifications
    static let saveButtonPressed: Handler<Void> = .init()
    static let screenshotSuccessNotificationPressed: Handler<Void> = .init()
}
