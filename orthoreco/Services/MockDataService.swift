//
//  MockDataService.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 16/03/2026.
//

import Foundation

final class MockDataService {
    let todaySteps = 4231
    let walkingSpeed = 1.12

    let weeklySteps: [DailyMetric] = [
        DailyMetric(day: "Mon", steps: 2100),
        DailyMetric(day: "Tue", steps: 2800),
        DailyMetric(day: "Wed", steps: 3200),
        DailyMetric(day: "Thu", steps: 3900),
        DailyMetric(day: "Fri", steps: 4231),
        DailyMetric(day: "Sat", steps: 4100),
        DailyMetric(day: "Sun", steps: 4550)
    ]
    
    let recoveryProgress = RecoveryProgress(
        preOpAverageSteps: 6000,
        currentAverageSteps: 4231,
        recoveryPercentage: 71
    )
}
