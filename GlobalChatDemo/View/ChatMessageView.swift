//
//  ChatMessageView.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import SwiftUI

struct ChatMessageView: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: message.isSentByCurrentUser ? .trailing : .leading, spacing: 4) {
            // ユーザー名をアイコンの上に表示
            HStack {
                if !message.isSentByCurrentUser {
                    // 受信メッセージ: 左側にユーザー名とアイコン、テキスト
                    VStack(spacing: 2) {
                        Text(message.senderName)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    Text(message.text)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    Spacer()
                } else {
                    // 送信メッセージ: 右側にテキストと、ユーザー名とアイコン
                    Spacer()
                    Text(message.text)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    VStack(spacing: 2) {
                        Text(message.senderName)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }
            }
            // タイムスタンプ表示
            HStack {
                if message.isSentByCurrentUser {
                    Spacer()
                    Text(formattedDate(message.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text(formattedDate(message.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"  // 例: 14:35
        return formatter.string(from: date)
    }
}
