//
//  ChatView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 21/02/26.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var vm: ChatViewModel
    @State private var isEditingTitle = false
    @State private var editedTitle = ""

    var onOpenChatList: () -> Void
    var onOpenSettings: () -> Void

    init(session: ChatSession, onOpenChatList: @escaping () -> Void, onOpenSettings: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: ChatViewModel(session: session))
        self.onOpenChatList = onOpenChatList
        self.onOpenSettings = onOpenSettings
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider().background(Color(white: 0.15))
            messageList
            Divider().background(Color(white: 0.15))
            inputBar
        }
        .background(Color.black)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 12) {
            // Chat list menu icon
            Button { onOpenChatList() } label: {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 20))
                    .foregroundColor(Color(white: 0.7))
            }

            Spacer()

            // Editable title
            if isEditingTitle {
                TextField("Chat name", text: $editedTitle, onCommit: {
                    if !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        vm.session.title = editedTitle
                        PersistenceController.shared.save()
                    }
                    isEditingTitle = false
                })
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
            } else {
                Text(vm.session.title ?? "New Chat")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            // Edit title button
            Button {
                editedTitle = vm.session.title ?? "New Chat"
                isEditingTitle.toggle()
            } label: {
                Image(systemName: isEditingTitle ? "checkmark" : "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.5))
            }

            Spacer()

            // Settings icon
            Button { onOpenSettings() } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(Color(white: 0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
    }

    // MARK: - Message List
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(vm.messages, id: \.id) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if vm.isGenerating {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: vm.messages.count) { _ in
                withAnimation {
                    if vm.isGenerating {
                        proxy.scrollTo("typing", anchor: .bottom)
                    } else {
                        proxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: vm.isGenerating) { _ in
                withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
            }
        }
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Message...", text: $vm.inputText, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(white: 0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .foregroundColor(.white)
                .font(.system(size: 15))

            Button {
                vm.sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isGenerating
                        ? LinearGradient(colors: [Color(white: 0.25), Color(white: 0.25)],
                                         startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [.green, .blue],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .disabled(vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isGenerating)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black)
    }
}


