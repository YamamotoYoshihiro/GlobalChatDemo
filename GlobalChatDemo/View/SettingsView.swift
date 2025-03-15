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
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ユーザー設定")) {
                    TextField("ユーザー名を入力", text: $username)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button("保存") {
                        // 既に登録済みのユーザー名を取得
                        let currentStored = UserDefaults.standard.string(forKey: "myUserName") ?? ""
                        
                        // 新しい名前と同じならエラー
                        if currentStored == username {
                            errorMessage = "登録された名前と同じです"
                            showErrorAlert = true
                            return
                        }
                        
                        // Firestoreで新しい名前の重複チェック
                        FirestoreManager.shared.isUsernameTaken(username) { taken in
                            if taken {
                                // 既に使われていたらエラー
                                errorMessage = "このユーザー名は既に使用されています。別のユーザー名を入力してください。"
                                showErrorAlert = true
                            } else {
                                // 重複していない場合
                                // 古い名前を削除
                                FirestoreManager.shared.deleteUsername(currentStored) { deleteSuccess in
                                    if !deleteSuccess {
                                        // 削除失敗したらエラーアラート等の処理
                                        errorMessage = "古いユーザー名の削除に失敗しました"
                                        showErrorAlert = true
                                        return
                                    }
                                    // 古い名前の削除が成功したら、新しい名前を登録
                                    FirestoreManager.shared.registerUsername(username) { success in
                                        if success {
                                            // 新しい名前を UserDefaults に保存
                                            UserDefaults.standard.set(username, forKey: "myUserName")
                                            showSavedMessage = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                showSavedMessage = false
                                            }
                                        } else {
                                            errorMessage = "ユーザー名の登録に失敗しました。再度お試しください。"
                                            showErrorAlert = true
                                        }
                                    }
                                }
                            }
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
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("エラー"),
                      message: Text(errorMessage ?? "エラーが発生しました"),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
