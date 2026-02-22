//
//  SettingsView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = SettingsViewModel()
    @State private var showSignOutConfirm = false
    @State private var isKeyVisible = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.06).ignoresSafeArea()

                List {

                    // MARK: - User
                    if !vm.userName.isEmpty || !vm.userEmail.isEmpty {
                        Section {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.green, .blue],
                                                             startPoint: .topLeading,
                                                             endPoint: .bottomTrailing))
                                        .frame(width: 46, height: 46)
                                    Text(vm.userName.prefix(1).uppercased())
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(vm.userName)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text(vm.userEmail)
                                        .font(.caption)
                                        .foregroundColor(Color(white: 0.5))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color(white: 0.11))
                    }

                    // MARK: - Groq API Key
                    Section(header: Text("Groq API Key").foregroundColor(Color(white: 0.45))) {
                        HStack {
                            Group {
                                if isKeyVisible {
                                    TextField("gsk_...", text: $vm.groqAPIKey)
                                } else {
                                    SecureField("gsk_...", text: $vm.groqAPIKey)
                                }
                            }
                            .font(.system(size: 14, design: .monospaced))
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
                        .listRowBackground(Color(white: 0.11))

                        Link("Get a free key at console.groq.com →",
                             destination: URL(string: "https://console.groq.com/keys")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .listRowBackground(Color(white: 0.11))
                    }

                    // MARK: - Model Settings
                    Section(header: Text("Model").foregroundColor(Color(white: 0.45))) {
                        HStack {
                            Text("Cloud Model")
                                .foregroundColor(.white)
                            Spacer()
                            Text("llama-3.3-70b")
                                .foregroundColor(Color(white: 0.4))
                                .font(.system(size: 13))
                        }
                        .listRowBackground(Color(white: 0.11))

                        HStack {
                            Text("On-Device Model")
                                .foregroundColor(.white)
                            Spacer()
                            Text("LLM.swift")
                                .foregroundColor(Color(white: 0.4))
                                .font(.system(size: 13))
                        }
                        .listRowBackground(Color(white: 0.11))
                    }

                    // MARK: - Generation
                    Section(header: Text("Generation").foregroundColor(Color(white: 0.45))) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Temperature")
                                    .foregroundColor(.white)
                                Spacer()
                                Text(String(format: "%.1f", vm.temperature))
                                    .foregroundColor(Color(white: 0.4))
                                    .font(.system(size: 13, design: .monospaced))
                            }
                            Slider(value: $vm.temperature, in: 0...1, step: 0.1)
                                .tint(.green)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color(white: 0.11))
                    }

                    // MARK: - System Prompt
                    Section(header: Text("System Prompt").foregroundColor(Color(white: 0.45))) {
                        TextEditor(text: $vm.systemPrompt)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .listRowBackground(Color(white: 0.11))
                    }

                    // MARK: - Sign Out
                    Section {
                        Button(role: .destructive) {
                            showSignOutConfirm = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sign Out")
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                            }
                        }
                        .listRowBackground(Color(white: 0.11))
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        vm.save()
                        dismiss()
                    }
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(white: 0.5))
                }
            }
            .confirmationDialog("Sign out of HybridChat?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    vm.signOut(appState: appState)
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .presentationBackground(Color(white: 0.06))
    }
}
