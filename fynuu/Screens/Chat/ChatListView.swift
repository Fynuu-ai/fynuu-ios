//
//  ChatListView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//

import SwiftUI

struct ChatListView: View {
    @ObservedObject var listVM: ChatListViewModel
    @Binding var selectedSession: ChatSession?
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if listVM.sessions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 40, weight: .thin))
                            .foregroundColor(Color(white: 0.3))
                        Text("No chats yet")
                            .foregroundColor(Color(white: 0.4))
                    }
                } else {
                    List {
                        ForEach(listVM.sessions, id: \.id) { session in
                            Button {
                                selectedSession = session
                                isPresented = false
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title ?? "New Chat")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    if let date = session.updatedAt {
                                        Text(date.formatted(.relative(presentation: .named)))
                                            .font(.caption)
                                            .foregroundColor(Color(white: 0.4))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(
                                selectedSession?.id == session.id
                                ? Color(white: 0.12)
                                : Color.clear
                            )
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { listVM.delete(listVM.sessions[$0]) }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { isPresented = false }
                        .foregroundColor(Color(white: 0.6))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let session = listVM.createSession()
                        selectedSession = session
                        isPresented = false
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(white: 0.07))
    }
}
