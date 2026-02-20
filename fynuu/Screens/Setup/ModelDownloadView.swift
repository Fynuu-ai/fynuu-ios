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
            Text("Model Download Setup")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Button("Next") {
                appState.hasCompletedOnboarding = true
                appState.route = .homeChat
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
