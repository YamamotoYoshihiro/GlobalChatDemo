//
//  GlobalChatDemoApp.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import SwiftUI
import Firebase

@main
struct GlobalChatDemoApp: App {
    init() {
        FirebaseApp.configure() // Firebase の初期化
        
        // 初回起動時にユーザー名が未設定なら、テスト用にデフォルト値を設定する
        if UserDefaults.standard.string(forKey: "myUserName") == nil {
            // ここは各端末ごとに異なる値を設定する必要があります（例：Alice, Bob, ...）
            UserDefaults.standard.set("Alice", forKey: "myUserName")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
