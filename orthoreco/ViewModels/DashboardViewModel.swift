//
//  DashboardViewModel.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var dashboard: PatientDashboardResponse?
    @Published var isLoading = false
    @Published var errorMessage = ""

    func fetchDashboard() async {
        isLoading = true
        errorMessage = ""

        do {
            dashboard = try await AuthService.shared.getPatientDashboard()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
