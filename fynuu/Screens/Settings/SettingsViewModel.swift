//
//  SettingsViewModel.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

final class SettingsViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var groqAPIKey: String = ""
    @Published var systemPrompt: String = "You are a helpful AI assistant."
    @Published var temperature: Double = 0.7
    
    @EnvironmentObject var appState: AppState

    // UserDefaults keys
    private let systemPromptKey = "global_system_prompt"
    private let temperatureKey = "global_temperature"

    init() { load() }

    func load() {
        // Google user info
        if let user = GIDSignIn.sharedInstance.currentUser {
            userName = user.profile?.name ?? ""
            userEmail = user.profile?.email ?? ""
        }

        // Groq key
        groqAPIKey = KeychainHelper.read(key: "groq_api_key") ?? ""

        // Preferences
        systemPrompt = UserDefaults.standard.string(forKey: systemPromptKey)
            ?? "You are a helpful AI assistant."
        temperature = UserDefaults.standard.double(forKey: temperatureKey)
            .clamped(to: 0...1) == 0
            ? 0.7
            : UserDefaults.standard.double(forKey: temperatureKey)
    }

    func save() {
        KeychainHelper.save(key: "groq_api_key", value: groqAPIKey)
        UserDefaults.standard.set(systemPrompt, forKey: systemPromptKey)
        UserDefaults.standard.set(temperature, forKey: temperatureKey)
    }

    func signOut(appState: AppState) {
        GIDSignIn.sharedInstance.signOut()
        try? Auth.auth().signOut()
        KeychainHelper.delete(key: "groq_api_key")
        UserDefaults.standard.removeObject(forKey: systemPromptKey)
        UserDefaults.standard.removeObject(forKey: temperatureKey)
        appState.hasCompletedOnboarding = false
        appState.route = .splash
    }
}

// Helper to clamp Double
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
