//
//  ContentView.swift

//
//  Created by Keetha Nikhil on 20/02/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch appState.route {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .setup:
                // Replace with OnboardingCoordinatorView in Sprint 2
                Text("Setup Coming Soon")
                    .foregroundColor(.white)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .homeChat:
                // Replace with HomeView in Chat sprint
                Text("Chat Home Coming Soon")
                    .foregroundColor(.white)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.45), value: appState.route)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}
