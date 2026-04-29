//
//  RecoveryScoreCalculator.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 29/04/2026.
//

import Foundation

struct RecoveryScoreResult {
    let score: Int
    let status: String
    let message: String
}

struct RecoveryScoreCalculator {
    static func calculate(
        pain: Int,
        stiffness: Int,
        walkingDifficulty: Int,
        confidence: Int,
        swelling: Bool,
        exerciseCompleted: Bool
    ) -> RecoveryScoreResult {

        var score = 100

        score -= pain * 5
        score -= stiffness * 3
        score -= walkingDifficulty * 4
        score += confidence * 3

        if swelling {
            score -= 10
        }

        if exerciseCompleted {
            score += 5
        }

        score = max(0, min(100, score))

        if score >= 75 {
            return RecoveryScoreResult(
                score: score,
                status: "Good",
                message: "Your recovery looks positive today. Keep following your plan."
            )
        } else if score >= 45 {
            return RecoveryScoreResult(
                score: score,
                status: "Moderate",
                message: "Your recovery is progressing, but some symptoms still need monitoring."
            )
        } else {
            return RecoveryScoreResult(
                score: score,
                status: "Needs Attention",
                message: "Your symptoms suggest slower recovery today. Consider contacting your clinician if this continues."
            )
        }
    }
}
