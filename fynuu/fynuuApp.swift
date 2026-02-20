//
//  fynuuApp.swift
//  fynuu
//
//  Created by Keetha Nikhil on 20/02/26.
//

import SwiftUI

@main
struct fynuuApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
