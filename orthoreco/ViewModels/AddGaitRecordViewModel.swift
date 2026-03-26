//
//  AddGaitRecordViewModel.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation
import Combine

@MainActor
final class AddGaitRecordViewModel: ObservableObject {
    @Published var recordDate = Date()
    @Published var stepCount = ""
    @Published var walkingSpeed = ""
    @Published var cadence = ""
    @Published var distance = ""
    @Published var activeMinutes = ""

    @Published var isLoading = false
    @Published var errorMessage = ""

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func saveRecord() async -> Bool {
        errorMessage = ""

        guard let stepCountInt = Int(stepCount), stepCountInt >= 0 else {
            errorMessage = "Enter a valid step count."
            return false
        }

        let walkingSpeedDouble: Double? = walkingSpeed.isEmpty ? nil : Double(walkingSpeed)
        if !walkingSpeed.isEmpty && walkingSpeedDouble == nil {
            errorMessage = "Enter a valid walking speed."
            return false
        }

        let cadenceDouble: Double? = cadence.isEmpty ? nil : Double(cadence)
        if !cadence.isEmpty && cadenceDouble == nil {
            errorMessage = "Enter a valid cadence."
            return false
        }

        let distanceDouble: Double? = distance.isEmpty ? nil : Double(distance)
        if !distance.isEmpty && distanceDouble == nil {
            errorMessage = "Enter a valid distance."
            return false
        }

        let activeMinutesInt: Int? = activeMinutes.isEmpty ? nil : Int(activeMinutes)
        if !activeMinutes.isEmpty && activeMinutesInt == nil {
            errorMessage = "Enter valid active minutes."
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await AuthService.shared.createGaitRecord(
                recordDate: dateFormatter.string(from: recordDate),
                stepCount: stepCountInt,
                walkingSpeed: walkingSpeedDouble,
                cadence: cadenceDouble,
                distance: distanceDouble,
                activeMinutes: activeMinutesInt
            )
            clearForm()
            NotificationCenter.default.post(name: .dashboardShouldRefresh, object: nil)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func clearForm() {
        recordDate = Date()
        stepCount = ""
        walkingSpeed = ""
        cadence = ""
        distance = ""
        activeMinutes = ""
    }
}
