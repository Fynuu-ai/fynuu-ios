//
//  HomeView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var listVM = ChatListViewModel()
    @State private var selectedSession: ChatSession? = nil
    @State private var showSettings = false
    @State private var showChatList = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let session = selectedSession {
                // Active chat
                ChatView(
                    session: session,
                    onOpenChatList: { showChatList = true },
                    onOpenSettings: { showSettings = true }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                // No chat selected — show empty state
                emptyState
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedSession?.id)
        .sheet(isPresented: $showChatList) {
            ChatListView(
                listVM: listVM,
                selectedSession: $selectedSession,
                isPresented: $showChatList
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear { listVM.fetch() }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(LinearGradient(
                    colors: [.green, .blue],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
            Text("No chats yet")
                .font(.title3.bold())
                .foregroundColor(.white)
            Text("Start a new conversation")
                .foregroundColor(Color(white: 0.5))
            Spacer()
            Button {
                let session = listVM.createSession()
                selectedSession = session
            } label: {
                Label("New Chat", systemImage: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
}
