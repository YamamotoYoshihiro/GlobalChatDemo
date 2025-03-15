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
    @State private var newPartnerName: String = ""
    @State private var newConversationName: String = ""
    
    var body: some View {
        NavigationView {
            List(viewModel.conversations) { conversation in
                // 会話タイトルが空の場合は "Unnamed Conversation" とする
                let title = conversation.name?.isEmpty == false ? conversation.name! : "Unnamed Conversation"
                // NavigationLink で、会話ID と 会話タイトルを渡す
                NavigationLink(destination: ChatView(conversationID: conversation.id, conversationTitle: title)) {
                    Text("\(title) (\(conversation.partnerName))")
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteConversation(conversationID: conversation.id) { success in
                            // 削除成功時の処理（必要なら）
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
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
                    TextField("Partner User Name", text: $newPartnerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
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
