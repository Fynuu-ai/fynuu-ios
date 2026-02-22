//
//  LocalLLMService.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//
import Foundation
import LLM

// Subclass using convenience init exactly as the library intends
class Bot: LLM {
    convenience init?(modelURL: URL, systemPrompt: String) {
        self.init(from: modelURL, template: .chatML(systemPrompt))
    }
}

@MainActor
final class LocalLLMService: ObservableObject {
    static let shared = LocalLLMService()

    @Published var isLoaded = false
    @Published var isLoading = false
    @Published var loadError: String? = nil

    // Exposed so ChatView can bind to bot.output for streaming
    private(set) var bot: Bot?

    private var systemPrompt: String {
        UserDefaults.standard.string(forKey: "global_system_prompt")
            ?? "You are a helpful AI assistant."
    }

    // MARK: - Load

    func loadModel() async {
        // Guard against both flags AND actual bot existence
        guard !isLoading else { return }
        guard !isLoaded || bot == nil else { return }  // ← key fix

        let modelURL = ModelDownloadService.shared.localModelURL
        guard FileManager.default.fileExists(atPath: modelURL.path) else {
            loadError = "Model not found. Please re-download."
            return
        }

        // Reset state cleanly
        isLoaded = false
        isLoading = true
        loadError = nil

        let url = modelURL
        let prompt = systemPrompt

        let result = await Task.detached(priority: .userInitiated) {
            Bot(modelURL: url, systemPrompt: prompt)
        }.value

        if let result {
            bot = result
            isLoaded = true
        } else {
            loadError = "Failed to load model. The file may be corrupted."
        }

        isLoading = false
    }

    // MARK: - Generate
    func generate(
        history: [ChatMessage],
        onToken: @escaping (String) -> Void,
        onComplete: @escaping (String) -> Void
    ) async {
        guard let bot else {
            onComplete("Model not loaded.")
            return
        }

        // Track new tokens by diffing output length
        var lastLength = 0

        bot.update = { _ in
            let current = bot.output
            guard current.count > lastLength else { return }
            let newToken = String(current.suffix(current.count - lastLength))
            lastLength = current.count
            DispatchQueue.main.async { onToken(newToken) }
        }

        let userInput = history.last?.content ?? ""
        await bot.respond(to: userInput)

        let finalOutput = bot.output
        DispatchQueue.main.async { onComplete(finalOutput) }
    }
    
    func unload() {
        bot = nil
        isLoaded = false
    }
}
