//
//  ChatView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 21/02/26.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text("Chat View")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                
            Button("Reset Setup (Demo)") {
                appState.hasCompletedOnboarding = false
                appState.route = .splash
            }
            .buttonStyle(.bordered)
            .padding(.top, 40)
        }
    }
}

