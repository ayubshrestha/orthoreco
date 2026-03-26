//
//  RegisterViewModel.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var gender = "Male"
    @Published var dateOfBirth = Date()

    @Published var patientID = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var surgeryType = "Knee Arthroplasty"
    @Published var surgerySide = "Left"
    @Published var surgeryDate = Date()

    @Published var isLoading = false
    @Published var errorMessage = ""

    let genders = ["Male", "Female", "Other", "Prefer not to say"]
    let surgeryTypes = ["Knee Arthroplasty", "Hip Arthroplasty"]
    let surgerySides = ["Left", "Right"]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func register() async -> Bool {
        errorMessage = ""

        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "First name is required."
            return false
        }

        guard !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Last name is required."
            return false
        }

        guard !patientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Patient ID is required."
            return false
        }

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

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await AuthService.shared.register(
                firstName: firstName,
                lastName: lastName,
                gender: gender,
                dateOfBirth: dateFormatter.string(from: dateOfBirth),
                patientID: patientID,
                email: email,
                password: password,
                surgeryType: surgeryType,
                surgerySide: surgerySide,
                surgeryDate: dateFormatter.string(from: surgeryDate)
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
