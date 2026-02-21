//
//  ModelDownloadView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 21/02/26.
//

import SwiftUI

struct ModelDownloadView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            
            let apiKey = KeychainHelper.read(key: "groq_api_key")
            Text("Model Download Screen")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Text("Your groq api key is:"+(apiKey ?? "No api key found"))
                .font(.caption)
                .foregroundColor(.white)
                .bold()
            
            
            Button("Next") {
                appState.hasCompletedOnboarding = true
                appState.route = .homeChat
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func readFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.fynuu",
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
