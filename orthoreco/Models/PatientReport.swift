//
//  PatientReport.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 29/04/2026.
//

import Foundation

struct PatientReport: Codable, Identifiable {
    let id: Int
    let userId: Int
    let reportDate: String
    let painScore: Int
    let stiffnessScore: Int
    let walkingDifficulty: Int
    let confidenceScore: Int
    let swelling: Bool
    let exerciseCompleted: Bool
    let notes: String?
    let createdAt: String?

    let recoveryScore: Int
    let recoveryStatus: String
    let recoveryMessage: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case reportDate = "report_date"
        case painScore = "pain_score"
        case stiffnessScore = "stiffness_score"
        case walkingDifficulty = "walking_difficulty"
        case confidenceScore = "confidence_score"
        case swelling = "swelling_flag"
        case exerciseCompleted = "exercise_completed"
        case notes
        case createdAt = "created_at"
        case recoveryScore = "recovery_score"
        case recoveryStatus = "recovery_status"
        case recoveryMessage = "recovery_message"
    }
}
