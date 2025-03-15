//
//  ConversationsListView.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import SwiftUI

struct ConversationsListView: View {
    @ObservedObject var viewModel = ConversationsViewModel()
    @State private var showingCreateConversation = false
    @State private var newPartnerName: String = ""       // パートナーのユーザー名入力
    @State private var newConversationName: String = ""    // 会話タイトル入力
    
    var body: some View {
        NavigationView {
            List(viewModel.conversations) { conversation in
                NavigationLink(destination: ChatView(conversationID: conversation.id)) {
                    // 会話タイトルを取得（空の場合は "Unnamed Conversation" とする）
                    let title = conversation.name?.isEmpty == false ? conversation.name! : "Unnamed Conversation"
                    // セルに「タイトル (パートナーのユーザー名)」を表示
                    Text("\(title) (\(conversation.partnerName))")
                }
            }
            .navigationTitle("Conversations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New") {
                        showingCreateConversation = true
                    }
                }
            }
            .sheet(isPresented: $showingCreateConversation) {
                VStack(spacing: 20) {
                    Text("Create Conversation")
                        .font(.headline)
                    // パートナーのユーザー名入力
                    TextField("Partner User Name", text: $newPartnerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    // 会話タイトル入力
                    TextField("Conversation Title", text: $newConversationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button("Create") {
                        viewModel.createConversation(with: newPartnerName, name: newConversationName) { conversationID in
                            showingCreateConversation = false
                            newPartnerName = ""
                            newConversationName = ""
                        }
                    }
                    .padding(.top)
                    Spacer()
                }
                .padding()
            }
        }
    }
}

struct ConversationsListView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsListView()
    }
}
