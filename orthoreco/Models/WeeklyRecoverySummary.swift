//
//  WeeklyRecoverySummary.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 29/04/2026.
//

import Foundation

struct WeeklyRecoverySummary: Codable {
    let totalCheckins: Int
    let averagePain: Double
    let averageStiffness: Double
    let averageWalkingDifficulty: Double
    let averageConfidence: Double
    let exerciseCompletionPercentage: Double
    let swellingDays: Int
    let missingDates: [String]
    let missedDaysCount: Int
    let currentStreak: Int
    let trendMessage: String
    let riskMessage: String

    enum CodingKeys: String, CodingKey {
        case totalCheckins = "total_checkins"
        case averagePain = "average_pain"
        case averageStiffness = "average_stiffness"
        case averageWalkingDifficulty = "average_walking_difficulty"
        case averageConfidence = "average_confidence"
        case exerciseCompletionPercentage = "exercise_completion_percentage"
        case swellingDays = "swelling_days"
        case missingDates = "missing_dates"
        case missedDaysCount = "missed_days_count"
        case currentStreak = "current_streak"
        case trendMessage = "trend_message"
        case riskMessage = "risk_message"
    }
}
