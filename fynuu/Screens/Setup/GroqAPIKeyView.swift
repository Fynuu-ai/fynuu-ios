//
//  GroqAPIKeyView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 20/02/26.
//

import SwiftUI
import Security

struct GroqAPIKeyView: View {
    @EnvironmentObject var appState: AppState
    @State private var apiKey = ""
    @State private var isKeyVisible = false
    @FocusState private var fieldFocused: Bool

    private var canContinue: Bool {
        apiKey.trimmingCharacters(in: .whitespacesAndNewlines).count > 10
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 100, height: 100)
                    Image(systemName: "key.horizontal")
                        .font(.system(size: 44, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(colors: [.green, .blue],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                }

                Spacer().frame(height: 32)

                VStack(spacing: 10) {
                    Text("Groq API Key")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Your key is stored securely in the device Keychain and never leaves your phone.")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer().frame(height: 48)

                // Input field
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.5))
                        .padding(.horizontal, 4)

                    HStack(spacing: 12) {
                        Group {
                            if isKeyVisible {
                                TextField("gsk_...", text: $apiKey)
                            } else {
                                SecureField("gsk_...", text: $apiKey)
                            }
                        }
                        .focused($fieldFocused)
                        .font(.system(size: 15, design: .monospaced))
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                        Button {
                            isKeyVisible.toggle()
                        } label: {
                            Image(systemName: isKeyVisible ? "eye.slash" : "eye")
                                .foregroundColor(Color(white: 0.4))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                fieldFocused ? Color.green.opacity(0.6) : Color(white: 0.2),
                                lineWidth: 1
                            )
                    )
                }
                .padding(.horizontal, 32)

                Link("Get a free Groq API key →",
                     destination: URL(string: "https://console.groq.com/keys")!)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 12)

                Spacer()

                Button {
                    saveAndContinue()
                } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            canContinue
                            ? LinearGradient(colors: [.green, .blue],
                                             startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color(white: 0.25), Color(white: 0.25)],
                                             startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(!canContinue)
                .padding(.horizontal, 32)

                Spacer().frame(height: 48)
            }
        }
        .onTapGesture { fieldFocused = false }
    }
    private func saveAndContinue() {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        KeychainHelper.save(key: "groq_api_key", value: trimmed)
        appState.route = .setup(.modelDownload)
    }
}
