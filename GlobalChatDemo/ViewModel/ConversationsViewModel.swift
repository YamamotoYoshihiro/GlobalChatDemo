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
extension Conversation {
    var partnerName: String {
        // 現在のユーザー名を UserDefaults から取得
        let myName = UserDefaults.standard.string(forKey: "myUserName") ?? "Guest"
        // 自分以外の参加者名を返す
        return participants.first { $0 != myName } ?? "Unknown"
    }
}

// MARK: - ConversationsViewModel
class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    // 各会話の未読件数を保持する辞書
    @Published var unreadCounts: [String: Int] = [:]
    private var db = Firestore.firestore()
    
    // 現在のユーザー名を取得
    private var myUserName: String {
        return UserDefaults.standard.string(forKey: "myUserName") ?? "Guest"
    }
    
    init() {
        fetchConversations()
    }
    
    func fetchConversations() {
        db.collection("conversations")
            .whereField("participants", arrayContains: myUserName)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No conversations")
                    return
                }
                var fetchedConversations: [Conversation] = []
                for doc in documents {
                    let data = doc.data()
                    guard let participants = data["participants"] as? [String] else { continue }
                    let name = data["name"] as? String
                    let conversation = Conversation(id: doc.documentID, participants: participants, name: name)
                    fetchedConversations.append(conversation)
                    
                    // 各会話ごとに未読件数のリスナーを設定する
                    self.setupUnreadListener(for: conversation.id)
                }
                DispatchQueue.main.async {
                    self.conversations = fetchedConversations
                }
            }
    }
    
    private func setupUnreadListener(for conversationID: String) {
        let messagesRef = db.collection("conversations")
            .document(conversationID)
            .collection("messages")
            .whereField("senderName", isNotEqualTo: myUserName)
            .whereField("isRead", isEqualTo: false)
        
        messagesRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error listening for unread messages: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            let count = snapshot.documents.count
            DispatchQueue.main.async {
                self.unreadCounts[conversationID] = count
                // 全体の未読数を合計してアプリアイコンのバッジに反映する
                let totalUnread = self.unreadCounts.values.reduce(0, +)
                BadgeManager.shared.updateAppBadge(unreadCount: totalUnread)
            }
        }
    }
    
    func createConversation(with partnerName: String, name: String? = nil, completion: @escaping (String?) -> Void) {
        let myName = myUserName
        let sortedNames = [myName, partnerName].sorted()
        let conversationTitle = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let sanitizedTitle = conversationTitle
            .replacingOccurrences(of: "/", with: "／")
            .replacingOccurrences(of: " ", with: "-")
        let conversationID: String
        if !sanitizedTitle.isEmpty {
            conversationID = sortedNames.joined(separator: "_") + "_" + sanitizedTitle
        } else {
            conversationID = sortedNames.joined(separator: "_")
        }
        let conversationData: [String: Any] = [
            "participants": [myName, partnerName],
            "name": conversationTitle
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
        conversationRef.collection("messages").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching messages for deletion: \(error)")
                completion(false)
                return
            }
            
            let batch = self.db.batch()
            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            batch.commit { error in
                if let error = error {
                    print("Error deleting messages: \(error)")
                    completion(false)
                } else {
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
    
    // 既読に更新する処理。会話ルームを開いたタイミングで呼ばれる
    func markMessagesAsRead(for conversationID: String) {
        let messagesRef = db.collection("conversations")
            .document(conversationID)
            .collection("messages")
            .whereField("isRead", isEqualTo: false)
        
        messagesRef.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No unread messages for conversation \(conversationID)")
                return
            }
            for doc in documents {
                let data = doc.data()
                if let senderName = data["senderName"] as? String, senderName != self.myUserName {
                    doc.reference.updateData(["isRead": true]) { error in
                        if let error = error {
                            print("Error marking message as read: \(error.localizedDescription)")
                        } else {
                            print("Message \(doc.documentID) in conversation \(conversationID) marked as read")
                        }
                    }
                }
            }
        }
    }
}
