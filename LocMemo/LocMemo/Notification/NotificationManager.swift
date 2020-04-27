//
//  NotificationManager.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/26/20.
//  Copyright © 2020 x. All rights reserved.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("requestNotificationPermission error=\(error)")
                return
            }
        }
    }

    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }

            if settings.alertSetting == .enabled {
                // The app’s notifications are displayed in Notification Center.
                // TODO: Schedule an alert-only notification.
            } else {
                // TODO: Schedule a notification with a badge and sound.
            }
        }
    }

    func getAuthorizationStatus(callback: @escaping(UNAuthorizationStatus) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            callback(settings.authorizationStatus)
        }
    }

    func getAuthorizationStatusStr(_ authStatus: UNAuthorizationStatus) -> String {
        if authStatus == .authorized {
            return "Authorized"
        } else if authStatus == .denied {
            return "Denied"
        } else if authStatus == .notDetermined {
            return "Ask next time"
        } else if authStatus == .provisional {
            return "Provisional"
        } else {
            return "Unknown"
        }
    }

    func updateStatusStr() {
        getAuthorizationStatus(callback: { status in
            DispatchQueue.main.async {
                ExternalSettings.shared.notificationAuthStatus = self.getAuthorizationStatusStr(status)
            }
        })
    }
}
