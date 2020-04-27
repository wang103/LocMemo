//
//  NotificationManager.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/26/20.
//  Copyright © 2020 x. All rights reserved.
//

import UserNotifications

class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private let center: UNUserNotificationCenter

    override init() {
        self.center = UNUserNotificationCenter.current()

        super.init()

        self.center.delegate = self
    }

    func requestNotificationPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("requestNotificationPermission error=\(error)")
                return
            }
        }
    }

    func scheduleNotification(memo: LocMemoData) {
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }

            if settings.alertSetting == .enabled {
                // Notifications can be displayed in Notification Center.
                // Schedule an alert and sound.
                self.registerNotification(memo: memo)
            } else {
                // Can schedule a badge and sound, but not useful. Do nothing.
            }
        }
    }

    // Register an alert and sound notification.
    fileprivate func registerNotification(memo: LocMemoData) {
        let content = UNMutableNotificationContent()
        content.title = "You arrived at a memo location"
        content.subtitle = memo.locationText
        content.body = memo.memoText
        content.sound = .default

        let request = UNNotificationRequest(identifier: memo.id, content: content, trigger: nil)

        // Schedule the request with the system.
        center.add(request) { (error) in
           if error != nil {
              print("registerNotification error=\(error!)")
           }
        }
    }

    func getAuthorizationStatus(callback: @escaping(UNAuthorizationStatus) -> Void) {
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

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {

        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // user opened the app
            let uuid = response.notification.request.identifier
            ExternalSettings.shared.displayMemo(id: uuid)
            break
        case UNNotificationDismissActionIdentifier:
            // user dismissed the notification
            break
        default:
            break
        }

        // Always call the completion handler when done.
        completionHandler()
    }
}
