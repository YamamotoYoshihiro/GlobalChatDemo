//
//  AppDelegate.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/18.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // UNUserNotificationCenter の delegate を AppDelegate に設定
        UNUserNotificationCenter.current().delegate = self
        // リモート通知の登録を開始
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Device Token: \(tokenString)")
        // ここでサーバーにトークンを送る処理を追加
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // フォアグラウンドでも通知を表示するためのデリゲートメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("=== willPresentが呼ばれました ===")
        print("通知のpayload: \(notification.request.content.userInfo)")

        // フォアグラウンドでも通知バナー、音、バッジを表示する
        completionHandler([.banner, .sound, .badge])
    }
}
