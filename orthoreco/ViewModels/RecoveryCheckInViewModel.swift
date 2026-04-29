//
//  RecoveryCheckInViewModel.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 29/04/2026.
//

import Foundation
import Combine

@MainActor
final class RecoveryCheckInViewModel: ObservableObject {
    @Published var painScore: Double = 5
    @Published var stiffnessScore: Double = 5
    @Published var walkingDifficulty: Double = 5
    @Published var confidenceScore: Double = 5

    @Published var swelling = false
    @Published var exerciseCompleted = false
    @Published var notes = ""

    @Published var isSaving = false
    @Published var showSuccess = false
    @Published var errorMessage: String?

    var recoveryResult: RecoveryScoreResult {
        RecoveryScoreCalculator.calculate(
            pain: Int(painScore),
            stiffness: Int(stiffnessScore),
            walkingDifficulty: Int(walkingDifficulty),
            confidence: Int(confidenceScore),
            swelling: swelling,
            exerciseCompleted: exerciseCompleted
        )
    }

    func saveReport() async {
        isSaving = true
        errorMessage = nil

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let payload: [String: Any] = [
            "report_date": formatter.string(from: Date()),
            "pain_score": Int(painScore),
            "stiffness_score": Int(stiffnessScore),
            "walking_difficulty": Int(walkingDifficulty),
            "confidence_score": Int(confidenceScore),
            "swelling_flag": swelling,
            "exercise_completed": exerciseCompleted,
            "notes": notes
        ]

        do {
            try await ReportService.shared.submitReport(request: payload)

            showSuccess = true
            NotificationCenter.default.post(name: .reportSaved, object: nil)

            notes = ""
        } catch {
            errorMessage = "Failed to save recovery check-in. Please try again."
        }

        isSaving = false
    }
}
