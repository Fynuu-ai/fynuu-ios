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

            case .setup(let step):
                switch step {
                case .googleSignIn:
                    GoogleSignInView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                case .groqAPIKey:
                    GroqAPIKeyView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                case .modelDownload:
                    ModelDownloadView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }

            case .homeChat:
                HomeView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.45), value: appState.route)
    }
}

/*
 #Preview {
 ContentView()
 .environment(\.managedObjectContext, //PersistenceController.preview.container.viewContext
 )
 .environmentObject(AppState())
 }
 */
