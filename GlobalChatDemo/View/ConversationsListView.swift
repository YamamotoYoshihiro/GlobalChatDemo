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
            List {
                ForEach(viewModel.conversations) { conversation in
                    // NavigationLink を HStack でラップして、その HStack に swipeActions を適用
                    HStack {
                        NavigationLink(destination: ChatView(conversationID: conversation.id)) {
                            let title = conversation.name?.isEmpty == false ? conversation.name! : "Unnamed Conversation"
                            Text("\(title) (\(conversation.partnerName))")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteConversation(conversationID: conversation.id) { success in
                                // 必要なら削除成功時の処理
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
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
