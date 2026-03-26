//
//  orthorecoApp.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 16/03/2026.
//

import SwiftUI

@main
struct orthorecoApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("hasConsented") private var hasConsented = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if !hasSeenWelcome {
                WelcomeView(hasEnteredApp: $hasSeenWelcome)
            } else if !hasConsented {
                ConsentView(hasConsented: $hasConsented)
            } else if !isLoggedIn {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}
