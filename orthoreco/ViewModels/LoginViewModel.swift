//
//  LoginViewModel.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var successMessage = ""

    func login() async -> Bool {
        errorMessage = ""
        successMessage = ""

        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Email is required."
            return false
        }

        guard email.contains("@") else {
            errorMessage = "Please enter a valid email."
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Password is required."
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await AuthService.shared.login(email: email, password: password)
            TokenManager.shared.saveToken(response.access_token, tokenType: response.token_type)
            successMessage = "Logged in successfully."
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
