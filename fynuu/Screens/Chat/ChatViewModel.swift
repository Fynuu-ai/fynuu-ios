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
    @Published var streamingText = ""

    var session: ChatSession
    private let context = PersistenceController.shared.context
    private let analyzer = PromptAnalyzer.shared
    private let llm = LocalLLMService.shared

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

    // MARK: - Send

    func sendMessage() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isGenerating else { return }

        inputText = ""
        addMessage(role: "user", content: trimmed)

        // Auto-title session
        if session.title == "New Chat" {
            session.title = String(trimmed.prefix(30))
            session.updatedAt = Date()
            PersistenceController.shared.save()
        }

        isGenerating = true
        streamingText = ""

        // Analyze prompt
        let complexity = analyzer.analyze(trimmed)

        switch complexity {
        case .basic:
            await generateOnDevice()
        case .complex:
            await generateCloudDemo()
        }
    }

    // MARK: - On-Device (LLM.swift)

    private func generateOnDevice() async {
        await llm.generate(
            history: messages,
            onToken: { [weak self] token in
                guard let self else { return }
                self.streamingText += token
            },
            onComplete: { [weak self] fullOutput in
                guard let self else { return }
                // Use fullOutput from bot.output (source of truth)
                self.addMessage(role: "assistant", content: fullOutput, route: "local")
                self.streamingText = ""
                self.isGenerating = false
            }
        )
    }

    // MARK: - Cloud (demo for now)

    private func generateCloudDemo() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        addMessage(
            role: "assistant",
            content: "☁️ This is a complex prompt — Groq Cloud LLM will handle this in the next sprint.",
            route: "cloud"
        )
        isGenerating = false
    }

    // MARK: - Core Data

    private func addMessage(role: String, content: String, route: String = "local") {
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
