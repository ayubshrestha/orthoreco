//
//  TokenManager.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()

    private let tokenKey = "authToken"
    private let tokenTypeKey = "authTokenType"

    private init() {}

    func saveToken(_ token: String, tokenType: String = "bearer") {
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(tokenType, forKey: tokenTypeKey)
    }

    func getToken() -> String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    func getTokenType() -> String? {
        UserDefaults.standard.string(forKey: tokenTypeKey)
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: tokenTypeKey)
    }

    func isLoggedIn() -> Bool {
        getToken() != nil
    }
}
