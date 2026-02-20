//
//  GoogleSignInView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 20/02/26.
//


import SwiftUI

struct GoogleSignInView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Google SignIn Setup")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Button("Next") {
                appState.route = .setup(.groqAPIKey)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
