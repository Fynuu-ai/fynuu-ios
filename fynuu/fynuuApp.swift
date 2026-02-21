//
//  fynuuApp.swift
//  fynuu
//
//  Created by Keetha Nikhil on 20/02/26.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct fynuuApp: App {
    @StateObject private var appState = AppState()
    let persistenceController = PersistenceController.shared
    
    init()
    {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
