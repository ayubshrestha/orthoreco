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
    let dailyStepGoal = 5000
    
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
    
    let patientProfile = PatientProfile(
        patientID: "ORTHO-001",
        surgeryType: "Total Knee Replacement",
        surgerySide: "Right",
        daysSinceSurgery: 24,
        dataSource: "Mock Simulator Data"
    )
    
    let weeklyWalkingSpeed: [DailyWalkingSpeed] = [
        DailyWalkingSpeed(day: "Mon", speed: 0.82),
        DailyWalkingSpeed(day: "Tue", speed: 0.88),
        DailyWalkingSpeed(day: "Wed", speed: 0.93),
        DailyWalkingSpeed(day: "Thu", speed: 1.01),
        DailyWalkingSpeed(day: "Fri", speed: 1.12),
        DailyWalkingSpeed(day: "Sat", speed: 1.08),
        DailyWalkingSpeed(day: "Sun", speed: 1.15)
    ]
    
    let adherenceSummary = AdherenceSummary(
        recordedDays: 6,
        totalDays: 7
    )
}
