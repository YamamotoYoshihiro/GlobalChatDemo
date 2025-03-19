//
//  ChatView.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import SwiftUI

struct ChatView: View {
    let conversationID: String
    let conversationTitle: String  // 会話タイトル
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
            // ScrollViewReader で内部の ScrollView をプログラムで制御
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            ChatMessageView(message: message)
                                .id(message.id) // 各メッセージに一意のIDを割り当てる
                        }
                    }
                    .padding(.vertical)
                }
                // 画面表示時に、最新のメッセージへスクロールする
                .onAppear {
                    // 遅延させてスクロールすることで、メッセージ配列が更新されるのを待つ
                    DispatchQueue.main.async {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                // メッセージが更新された場合も、最新メッセージにスクロール
                .onChange(of: viewModel.messages) {
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            HStack {
                TextField("メッセージを入力...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button(action: {
                    guard !newMessage.isEmpty else { return }
                    viewModel.sendMessage(text: newMessage)
                    // キーボードを閉じる処理
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    newMessage = ""
                }) {
                    Text("送信")
                }
                .padding(.trailing)
            }
            .padding(.bottom, 10)
        }
        .navigationTitle(conversationTitle)
        // 会話ルームを開いたときに既読更新
        .onAppear {
            viewModel.markMessagesAsRead()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(conversationID: "Alice_Bob_ProjectChat", conversationTitle: "Project Chat")
    }
}
