//
//  ChatViewModel.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//

import CoreData
import SwiftUI

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isGenerating = false

    var session: ChatSession
    private let context = PersistenceController.shared.context
    
    private let analyzer = PromptAnalyzer.shared

    init(session: ChatSession) {
        self.session = session
        fetchMessages()
    }

    func fetchMessages() {
        let request = NSFetchRequest<ChatMessage>(entityName: "ChatMessage")
        request.predicate = NSPredicate(format: "session == %@", session)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        messages = (try? context.fetch(request)) ?? []
    }

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""

        // Save user message
        addMessage(role: "user", content: trimmed,route: "local")

        // Auto-title on first message
        if session.title == "New Chat" {
            session.title = String(trimmed.prefix(30))
            session.updatedAt = Date()
            PersistenceController.shared.save()
        }
        
        // Analyze prompt
                let complexity = analyzer.analyze(trimmed)

                switch complexity {
                case .basic:
                    // Demo response — real LLM wired in next sprint
                    isGenerating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.addMessage(role: "assistant", content: "This is a demo response. LLM will be wired in the next sprint.",route: "local")
                        self.isGenerating = false
                    }
                case .complex:
                    // Demo response — real LLM wired in next sprint
                    isGenerating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.addMessage(role: "assistant", content: "This is a demo response. LLM will be wired in the next sprint.",route: "cloud")
                        self.isGenerating = false
                    }
                }

        
    }

    private func addMessage(role: String, content: String, route: String) {
        let message = ChatMessage(context: context)
        message.id = UUID()
        message.role = role
        message.content = content
        message.timestamp = Date()
        message.routeUsed = route
        message.setValue(session, forKey: "session")
        session.updatedAt = Date()
        PersistenceController.shared.save()
        fetchMessages()
    }
}
