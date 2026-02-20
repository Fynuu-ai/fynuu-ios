//
//  AppState.swift
//
//  Created by Keetha Nikhil on 20/02/26.
//

import SwiftUI

enum AppRoute {
    case splash
    case setup
    case homeChat
}

@MainActor
final class AppState: ObservableObject {
    @Published var route: AppRoute = .splash

    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedSetup") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedSetup") }
    }
}
