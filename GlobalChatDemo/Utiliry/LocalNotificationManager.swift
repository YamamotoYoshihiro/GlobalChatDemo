//
//  LocalNotificationManager.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/19.
//

import Foundation
import UserNotifications

final class LocalNotificationManager {
    static let shared = LocalNotificationManager()
    private init() {}

    /// 通知許可をリクエスト
    /// - `.badge, .sound, .alert` のうち必要なものを指定
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            } else {
                print("Notification authorization granted: \(granted)")
            }
        }
    }

    /// サウンド付きローカル通知をスケジュール
    /// - senderName: 通知のタイトルとして使う文字列
    /// - messageText: 通知の本文として使う文字列
    /// - timeInterval: この秒数後に通知を出す（デフォルト3秒後）
    /// - badge: バッジ数（デフォルト3に設定）
    func scheduleSoundNotification(
        senderName: String,
        messageText: String,
        timeInterval: TimeInterval = 3,
        badge: Int = 3
    ) {
        let content = UNMutableNotificationContent()
        // タイトルに送信者の名前、本文にメッセージ本文を設定
        content.title = senderName
        content.body = messageText

        // サウンドを鳴らすための設定
        content.sound = .default
        
        // バッジを更新したい場合
        // ここを badge=0 にしてしまうとバッジは「0」になり、実質的に非表示と同じ
        content.badge = NSNumber(value: badge)

        // 指定秒数後に一度だけ発火するトリガー
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        // 通知リクエストを作成
        let request = UNNotificationRequest(
            identifier: "LocalNotificationSample",
            content: content,
            trigger: trigger
        )

        // 通知をスケジューリング
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error)")
            } else {
                print("Local notification scheduled successfully. (badge=\(badge))")
            }
        }
    }
}
