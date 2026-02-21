//
//  GoogleSignInView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 20/02/26.
//


import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

struct GoogleSignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

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
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(colors: [.green, .blue],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                }

                Spacer().frame(height: 32)

                // Heading
                VStack(spacing: 10) {
                    Text("Welcome to")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(white: 0.5))

                    Text("HybridChat")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Sign in to get started")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.45))
                }

                Spacer()

                // Error
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 16)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Google Sign-In button
                Button {
                    signIn()
                } label: {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .tint(.black)
                                .scaleEffect(0.85)
                        } else {
                            // Google "G" logo using SF Symbol fallback
                            Image(systemName: "globe")
                                .font(.system(size: 18, weight: .medium))
                            Text("Continue with Google")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(isLoading)
                .padding(.horizontal, 32)

                Spacer().frame(height: 48)
            }
        }
    }

    private func signIn() {
        isLoading = true
        errorMessage = nil
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase not configured correctly."
            isLoading = false
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to present sign-in screen."
            isLoading = false
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                errorMessage = "Sign-in failed. Please try again."
                return
            }
            
            // Create Firebase credential and sign in
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                // ✅ Signed in — move to next step
                appState.route = .setup(.groqAPIKey)
            }
        }
    }
}
