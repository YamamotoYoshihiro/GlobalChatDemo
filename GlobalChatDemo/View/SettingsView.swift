//
//  SettingsView.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import SwiftUI

struct SettingsView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "myUserName") ?? ""
    @State private var showSavedMessage: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ユーザー設定")) {
                    TextField("ユーザー名を入力", text: $username)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button("保存") {
                        UserDefaults.standard.set(username, forKey: "myUserName")
                        showSavedMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showSavedMessage = false
                        }
                    }
                }
                
                if showSavedMessage {
                    Section {
                        Text("保存しました！")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
