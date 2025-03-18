//
//  BadgeManager.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/18.
//

import UIKit
import UserNotifications

final class BadgeManager {
    static let shared = BadgeManager()
    private init() {}

    func updateAppBadge(unreadCount: Int) {
        DispatchQueue.main.async {
            if #available(iOS 17.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(unreadCount) { error in
                    if let error = error {
                        print("Error updating badge count: \(error.localizedDescription)")
                    }
                }
            } else {
                UIApplication.shared.applicationIconBadgeNumber = unreadCount
            }
        }
    }
}
