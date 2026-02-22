//
//  CloudLLMService.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//


import Foundation

final class CloudLLMService {
    static let shared = CloudLLMService()

    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"
    private let model = "meta-llama/llama-4-maverick-17b-128e-instruct" // gpt oss 120b on Groq

    // MARK: - Streaming generate

    func generate(
        messages: [[String: String]],
        onToken: @escaping (String) -> Void,
        onComplete: @escaping (String) -> Void,
        onError: @escaping (String) -> Void
    ) async {
        guard let apiKey = KeychainHelper.read(key: "groq_api_key"),
              !apiKey.isEmpty else {
            onError("No Groq API key found. Please add it in Settings.")
            return
        }

        guard let url = URL(string: baseURL) else {
            onError("Invalid API URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "stream": true,
            "max_tokens": 4096,
            "temperature": temperature
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            onError("Failed to encode request.")
            return
        }
        request.httpBody = httpBody

        do {
            let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

            guard let http = response as? HTTPURLResponse else {
                onError("Invalid response from server.")
                return
            }

            guard http.statusCode == 200 else {
                onError("Groq API error \(http.statusCode). Check your API key.")
                return
            }

            var fullOutput = ""

            // Parse SSE stream
            for try await line in asyncBytes.lines {
                guard line.hasPrefix("data: ") else { continue }
                let data = String(line.dropFirst(6))
                guard data != "[DONE]" else { break }

                guard
                    let jsonData = data.data(using: .utf8),
                    let chunk = try? JSONDecoder().decode(GroqStreamChunk.self, from: jsonData),
                    let token = chunk.choices.first?.delta.content,
                    !token.isEmpty
                else { continue }

                fullOutput += token
                onToken(token)
            }

            onComplete(fullOutput)

        } catch let error as NSError {
            if error.code == NSURLErrorNotConnectedToInternet ||
               error.code == NSURLErrorNetworkConnectionLost {
                onError("No internet connection.")
            } else {
                onError("Request failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Helpers

    private var temperature: Double {
        let saved = UserDefaults.standard.double(forKey: "global_temperature")
        return saved == 0 ? 0.7 : saved
    }

    /// Build messages array with system prompt + full chat history
    static func buildMessages(
        history: [ChatMessage],
        systemPrompt: String
    ) -> [[String: String]] {
        var messages: [[String: String]] = []

        // System prompt first
        messages.append([
            "role": "system",
            "content": systemPrompt
        ])

        // Full chat history for context
        for msg in history {
            guard let content = msg.content,
                  !content.isEmpty,
                  msg.role == "user" || msg.role == "assistant"
            else { continue }

            messages.append([
                "role": msg.role ?? "user",
                "content": content
            ])
        }

        return messages
    }
}

// MARK: - Response models

private struct GroqStreamChunk: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let delta: Delta
        struct Delta: Decodable {
            let content: String?
        }
    }
}
