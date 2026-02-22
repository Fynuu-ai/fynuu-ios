//
//  PromptAnalyzer.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//

import Foundation

enum PromptComplexity {
    case basic    // → on-device LLM
    case complex  // → cloud LLM
}

final class PromptAnalyzer {
    static let shared = PromptAnalyzer()

    // MARK: - Word lists

    private let complexTriggers: [String] = [
        // Code & engineering
        "write a", "build a", "create a", "implement", "develop",
        "code", "program", "function", "algorithm", "architecture",
        "debug", "refactor", "optimize", "api", "database", "backend",
        "frontend", "deploy", "dockerfile", "kubernetes", "sql",
        // Research & writing
        "research", "analyze", "analyse", "compare", "contrast",
        "essay", "report", "thesis", "dissertation", "literature review",
        "summarize this", "explain in detail", "step by step guide",
        "comprehensive", "in-depth", "detailed explanation",
        // Complex reasoning
        "proof", "theorem", "derive", "calculate", "solve",
        "business plan", "marketing strategy", "financial model",
        "translate this entire", "rewrite this",
        // Long-form
        "write me a story", "write a poem", "screenplay",
        "cover letter", "resume", "proposal"
    ]

    private let basicTriggers: [String] = [
        // Greetings
        "hi", "hello", "hey", "howdy", "good morning",
        "good afternoon", "good evening", "whats up", "what's up",
        // Simple questions
        "what is", "what are", "who is", "who was",
        "when did", "when was", "where is", "where are",
        "how do i", "how does", "why is", "why does",
        "define ", "meaning of", "tell me about",
        // Fun / casual
        "tell me a joke", "joke", "fun fact", "did you know",
        "what time", "weather", "capital of", "population of",
        // Simple tasks
        "translate", "spell", "synonym", "antonym",
        "yes", "no", "ok", "okay", "sure", "thanks", "thank you"
    ]

    // MARK: - Public API

    func analyze(_ prompt: String) -> PromptComplexity {
        let lower = prompt.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let score = complexityScore(lower)

        // Score > 0 = complex, Score <= 0 = basic
        return score > 0 ? .complex : .basic
    }

    // MARK: - Scoring

    private func complexityScore(_ lower: String) -> Int {
        var score = 0

        // +2 for each complex trigger hit
        for trigger in complexTriggers where lower.contains(trigger) {
            score += 2
        }

        // -1 for each basic trigger hit
        for trigger in basicTriggers where lower.contains(trigger) {
            score -= 1
        }

        // Word count signals
        let wordCount = lower.split(separator: " ").count
        if wordCount > 50  { score += 2 }
        if wordCount > 100 { score += 2 }
        if wordCount < 10  { score -= 1 }

        // Code block signal
        if lower.contains("```") || lower.contains("    ") { score += 3 }

        // Multi-question signal
        let questionMarks = lower.filter { $0 == "?" }.count
        if questionMarks > 2 { score += 1 }

        // Numbered list in prompt = structured complex request
        if lower.contains("1.") || lower.contains("1)") { score += 1 }

        return score
    }
}
