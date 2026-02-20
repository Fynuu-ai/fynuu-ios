//
//  ContentView.swift
//  fynuu
//
//  Created by Keetha Nikhil on 20/02/26.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationView {
            Text("Hello World!")
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
