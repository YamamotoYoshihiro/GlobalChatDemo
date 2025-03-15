//
//  MainTabView.swift
//  GlobalChatDemo
//
//  Created by 山本義弘 on 2025/03/15.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ConversationsListView()
                .tabItem {
                    Label("Conversations", systemImage: "message")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
