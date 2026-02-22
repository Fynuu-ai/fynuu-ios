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
    
    @Published var showCloudError = false
    @Published var cloudErrorMessage = ""

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
            await generateCloud()
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
    // MARK: - Cloud (Groq)

    private func generateCloud() async {
        let systemPrompt = UserDefaults.standard.string(forKey: "global_system_prompt")
            ?? "You are a helpful AI assistant."

        // Build messages with full history for context
        let groqMessages = CloudLLMService.buildMessages(
            history: messages,
            systemPrompt: systemPrompt
        )

        var cloudFailed = false
        var cloudError = ""

        await CloudLLMService.shared.generate(
            messages: groqMessages,
            onToken: { [weak self] token in
                guard let self else { return }
                self.streamingText += token
            },
            onComplete: { [weak self] fullOutput in
                guard let self else { return }
                self.addMessage(role: "assistant", content: fullOutput, route: "cloud")
                self.streamingText = ""
                self.isGenerating = false
            },
            onError: { error in
                cloudFailed = true
                cloudError = error
            }
        )

        // Fallback to on-device if cloud failed
        if cloudFailed {
            await handleCloudFallback(reason: cloudError)
        }
    }

    private func handleCloudFallback(reason: String) async {
        // Show error banner briefly
        await MainActor.run {
            self.cloudErrorMessage = reason
            self.showCloudError = true
        }

        // Small delay so user sees the error
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        await MainActor.run {
            self.showCloudError = false
            self.streamingText = ""
        }

        // Fallback to on-device
        await generateOnDevice()
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
