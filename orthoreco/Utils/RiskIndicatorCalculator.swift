//
//  RiskIndicatorCalculator.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 29/04/2026.
//

import Foundation

struct RiskIndicatorResult {
    let level: String
    let message: String
    let score: Int
}

struct RiskIndicatorCalculator {
    static func calculate(from reports: [PatientReport]) -> RiskIndicatorResult {
        guard let latest = reports.first else {
            return RiskIndicatorResult(
                level: "No Data",
                message: "Submit your first recovery check-in to see your risk status.",
                score: 0
            )
        }

        var riskScore = 0

        if latest.painScore >= 8 {
            riskScore += 35
        } else if latest.painScore >= 6 {
            riskScore += 20
        }

        if latest.swelling {
            riskScore += 25
        }

        if latest.walkingDifficulty >= 7 {
            riskScore += 20
        }

        if latest.confidenceScore <= 3 {
            riskScore += 15
        }

        if reports.count >= 3 {
            let recent = Array(reports.prefix(3))

            if recent[0].painScore > recent[1].painScore &&
                recent[1].painScore > recent[2].painScore {
                riskScore += 20
            }

            if recent[0].walkingDifficulty > recent[1].walkingDifficulty &&
                recent[1].walkingDifficulty > recent[2].walkingDifficulty {
                riskScore += 15
            }
        }

        riskScore = min(riskScore, 100)

        if riskScore >= 70 {
            return RiskIndicatorResult(
                level: "High Risk",
                message: "Your symptoms suggest increased recovery risk. Consider contacting your clinician if this continues.",
                score: riskScore
            )
        } else if riskScore >= 35 {
            return RiskIndicatorResult(
                level: "Moderate Risk",
                message: "Some recovery indicators need monitoring. Keep tracking your symptoms daily.",
                score: riskScore
            )
        } else {
            return RiskIndicatorResult(
                level: "Low Risk",
                message: "Your current recovery indicators look stable.",
                score: riskScore
            )
        }
    }
}
