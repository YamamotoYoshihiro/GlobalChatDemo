//
//  ContentView.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedConversation = 0
    // 各タプルの1つ目は会話タイトル、2つ目は相手ID
    let conversationOptions = [("A-B", "PartnerB"), ("A-C", "PartnerC")]
    
    var body: some View {
        VStack {
            Picker("Conversation", selection: $selectedConversation) {
                ForEach(0..<conversationOptions.count, id: \.self) { index in
                    Text(conversationOptions[index].0)
                        .tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            // ChatView の初期化時に conversationID と conversationTitle を渡す
            ChatView(
                conversationID: conversationOptions[selectedConversation].1,
                conversationTitle: conversationOptions[selectedConversation].0
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

