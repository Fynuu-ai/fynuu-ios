//
//  GroqAPIKeyView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 20/02/26.
//

import SwiftUI

struct GroqAPIKeyView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text("Groq API Key Setup")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Button("Next") {
                appState.route = .setup(.modelDownload)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
