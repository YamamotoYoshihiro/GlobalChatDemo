//
//  ChatView.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import SwiftUI

struct ChatView: View {
    let conversationID: String
    let conversationTitle: String  // 追加：会話タイトル
    @ObservedObject private var viewModel: ChatViewModel
    @State private var newMessage: String = ""
    
    // 初期化時に会話IDと会話タイトルを渡す
    init(conversationID: String, conversationTitle: String) {
        self.conversationID = conversationID
        self.conversationTitle = conversationTitle
        self.viewModel = ChatViewModel(conversationID: conversationID)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        ChatMessageView(message: message)
                    }
                }
                .padding(.vertical)
            }
            HStack {
                TextField("メッセージを入力...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button(action: {
                    guard !newMessage.isEmpty else { return }
                    viewModel.sendMessage(text: newMessage)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    newMessage = ""
                }) {
                    Text("送信")
                }
                .padding(.trailing)
            }
            .padding(.bottom, 10)
        }
        // ここで会話タイトルをナビゲーションタイトルに設定
        .navigationTitle(conversationTitle)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(conversationID: "Alice_Bob_ProjectChat", conversationTitle: "Project Chat")
    }
}

