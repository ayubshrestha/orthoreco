//
//  ProfileViewModel.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: UserResponse?
    @Published var isLoading = false
    @Published var errorMessage = ""

    func fetchProfile() async {
        isLoading = true
        errorMessage = ""

        do {
            user = try await AuthService.shared.getCurrentUser()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
