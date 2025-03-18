//
//  ChatViewModel.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import Foundation
import FirebaseFirestore
import Firebase

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let senderName: String
    let timestamp: Date
    let isRead: Bool
    
    var isSentByCurrentUser: Bool {
        return senderName == UserDefaults.standard.string(forKey: "myUserName")
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private var db = Firestore.firestore()
    
    private var conversationID: String
    
    // 現在のユーザー名を取得
    private var myUserName: String {
        return UserDefaults.standard.string(forKey: "myUserName") ?? "Guest"
    }
    
    init(conversationID: String) {
        self.conversationID = conversationID
        fetchMessages()
    }
    
    func fetchMessages() {
        db.collection("conversations")
            .document(conversationID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No messages for conversation \(self.conversationID)")
                    return
                }
                self.messages = documents.compactMap { doc in
                    let data = doc.data()
                    guard let text = data["text"] as? String,
                          let senderName = data["senderName"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp,
                          let isRead = data["isRead"] as? Bool else { return nil }
                    return Message(text: text,
                                   senderName: senderName,
                                   timestamp: timestamp.dateValue(),
                                   isRead: isRead)
                }
            }
    }
    
    func sendMessage(text: String) {
        let newMessage: [String: Any] = [
            "text": text,
            "senderName": myUserName,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false  // 初期状態は false
        ]
        db.collection("conversations")
            .document(conversationID)
            .collection("messages")
            .addDocument(data: newMessage) { error in
                if let error = error {
                    print("Error sending message: \(error)")
                }
            }
    }
    
    func markMessagesAsRead() {
        // まず、未読メッセージ（isRead == false）のドキュメントを取得
        let messagesRef = db.collection("conversations")
            .document(conversationID)
            .collection("messages")
            .whereField("isRead", isEqualTo: false)
        
        messagesRef.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No unread messages")
                return
            }
            for doc in documents {
                let data = doc.data()
                // 送信者が自分でない（＝相手からのメッセージ）場合のみ更新
                if let senderName = data["senderName"] as? String,
                   senderName != self.myUserName {
                    doc.reference.updateData(["isRead": true]) { error in
                        if let error = error {
                            print("Error marking message as read: \(error.localizedDescription)")
                        } else {
                            print("Message \(doc.documentID) marked as read")
                        }
                    }
                }
            }
        }
    }
}
