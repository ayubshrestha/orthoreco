//
//  SessionManager.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import SwiftUI

final class SessionManager {
    static let shared = SessionManager()

    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("hasConsented") var hasConsented = false

    private init() {}

    func login() {
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
    }
}
