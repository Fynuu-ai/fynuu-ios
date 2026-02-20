//
//  AppState.swift
//
//  Created by Keetha Nikhil on 20/02/26.
//

import SwiftUI

enum AppRoute: Equatable {
    case splash
    case setup(SetupStep)
    case homeChat
}

enum SetupStep: Equatable {
    case googleSignIn
    case groqAPIKey
    case modelDownload
}

@MainActor
final class AppState: ObservableObject {
    @Published var route: AppRoute = .splash

    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedSetup") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedSetup") }
    }
}
