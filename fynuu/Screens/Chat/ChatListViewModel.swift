//
//  ChatListViewModel.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//

import CoreData
import SwiftUI

final class ChatListViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []

    private let context = PersistenceController.shared.context

    init() { fetch() }

    func fetch() {
        let request = NSFetchRequest<ChatSession>(entityName: "ChatSession")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        sessions = (try? context.fetch(request)) ?? []
    }

    func createSession() -> ChatSession {
        let session = ChatSession(context: context)
        session.id = UUID()
        session.title = "New Chat"
        session.createdAt = Date()
        session.updatedAt = Date()
        PersistenceController.shared.save()
        fetch()
        return session
    }

    func delete(_ session: ChatSession) {
        context.delete(session)
        PersistenceController.shared.save()
        fetch()
    }

    func rename(_ session: ChatSession, to title: String) {
        session.title = title
        session.updatedAt = Date()
        PersistenceController.shared.save()
        fetch()
    }
}
