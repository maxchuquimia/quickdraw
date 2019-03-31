//
//  NotificationDelegate.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 31/3/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Foundation

class NotificationDelegate: NSObject, NSUserNotificationCenterDelegate {

    enum Identifier: String {
        case screenshotSuccess = "DBAAD179-35A3-4C42-A424-65A8DBFCD413"
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        
        guard let id = Identifier(rawValue: notification.identifier ?? "") else { return }

        switch id {
        case .screenshotSuccess: NotificationCenter.screenshotSuccessNotificationPressed.send()
        }
    }
}
