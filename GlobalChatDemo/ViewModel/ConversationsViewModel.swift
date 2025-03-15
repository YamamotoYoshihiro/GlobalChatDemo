//
//  ConversationsViewModel.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import Foundation
import FirebaseFirestore
import Firebase

// 会話ルームのモデル
struct Conversation: Identifiable {
    var id: String
    var participants: [String] // ユーザー名で管理
    var name: String?          // 会話タイトル
}

// MARK: - Partner Name Extension
// この extension により、現在のユーザー名以外の参加者名（＝パートナーのユーザー名）を取得します。
extension Conversation {
    var partnerName: String {
        // 現在のユーザー名を UserDefaults から取得
        let myName = UserDefaults.standard.string(forKey: "myUserName") ?? "Guest"
        // participants 配列から自分の名前以外のものを返す
        return participants.first { $0 != myName } ?? "Unknown"
    }
}

// MARK: - ConversationsViewModel
class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    private var db = Firestore.firestore()
    
    // 現在のユーザー名を UserDefaults から取得
    private var myUserName: String {
        return UserDefaults.standard.string(forKey: "myUserName") ?? "Guest"
    }
    
    init() {
        fetchConversations()
    }
    
    // Firestore から、自分のユーザー名が含まれる会話をリアルタイムに取得
    func fetchConversations() {
        db.collection("conversations")
            .whereField("participants", arrayContains: myUserName)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No conversations")
                    return
                }
                self.conversations = documents.compactMap { doc in
                    let data = doc.data()
                    guard let participants = data["participants"] as? [String] else { return nil }
                    let name = data["name"] as? String
                    return Conversation(id: doc.documentID, participants: participants, name: name)
                }
            }
    }
    
    /// 会話ルーム作成メソッド
    /// - Parameters:
    ///   - partnerName: 相手のユーザー名
    ///   - name: 会話タイトル（任意の文字列）。入力がなければ空文字
    ///   - completion: 作成完了後に生成された会話IDを返すクロージャ
    func createConversation(with partnerName: String, name: String? = nil, completion: @escaping (String?) -> Void) {
        let myName = myUserName
        // 両者のユーザー名を辞書順にソート
        let sortedNames = [myName, partnerName].sorted()
        
        // ユーザーが入力した会話タイトルをトリムし、禁止文字 "/" を全角 "／" に置換、スペースは "-" に置換
        let conversationTitle = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let sanitizedTitle = conversationTitle
            .replacingOccurrences(of: "/", with: "／")
            .replacingOccurrences(of: " ", with: "-")
        
        // 会話IDは、参加者の名前 + (タイトルがあればタイトルを付加) で生成
        let conversationID: String
        if !sanitizedTitle.isEmpty {
            conversationID = sortedNames.joined(separator: "_") + "_" + sanitizedTitle
        } else {
            conversationID = sortedNames.joined(separator: "_")
        }
        
        let conversationData: [String: Any] = [
            "participants": [myName, partnerName],
            "name": conversationTitle  // ユーザーが入力したタイトルそのまま保存
        ]
        
        db.collection("conversations").document(conversationID).setData(conversationData) { error in
            if let error = error {
                print("Error creating conversation: \(error)")
                completion(nil)
            } else {
                completion(conversationID)
            }
        }
    }

    func deleteConversation(conversationID: String, completion: @escaping (Bool) -> Void) {
        let conversationRef = db.collection("conversations").document(conversationID)
        
        // まず、会話ドキュメントの「messages」サブコレクションの全ドキュメントを取得
        conversationRef.collection("messages").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching messages for deletion: \(error)")
                completion(false)
                return
            }
            
            let batch = self.db.batch()
            
            // サブコレクションの各ドキュメントをバッチに追加
            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            // バッチコミットで全てのメッセージを削除
            batch.commit { error in
                if let error = error {
                    print("Error deleting messages: \(error)")
                    completion(false)
                } else {
                    // サブコレクションの削除が成功したら、会話ドキュメントを削除する
                    conversationRef.delete { error in
                        if let error = error {
                            print("Error deleting conversation: \(error)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                }
            }
        }
    }
}
