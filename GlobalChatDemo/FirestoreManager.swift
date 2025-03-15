//
//  FirestoreManager.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/16.
//

import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    // 指定されたユーザー名が既に存在するかチェックする
    func isUsernameTaken(_ username: String, completion: @escaping (Bool) -> Void) {
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking username: \(error)")
                    // エラー時はとりあえず重複とみなす（またはエラーハンドリングを別途実装）
                    completion(true)
                    return
                }
                // ドキュメントが1件以上あれば、すでに使用中
                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }
    
    // ユーザー名を登録する（自動生成されたドキュメントIDを使用）
    func registerUsername(_ username: String, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = ["username": username]
        db.collection("users").addDocument(data: data) { error in
            if let error = error {
                print("Error registering username: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func deleteUsername(_ username: String, completion: @escaping (Bool) -> Void) {
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error deleting username: \(error)")
                    completion(false)
                    return
                }
                guard let snapshot = snapshot else {
                    completion(false)
                    return
                }
                
                // バッチ処理でまとめて削除
                let batch = self.db.batch()
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { error in
                    if let error = error {
                        print("Error committing batch delete: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
    }
}
