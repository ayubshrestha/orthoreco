//
//  ProgressViewScreen.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 18/03/2026.
//

import SwiftUI
import Charts

struct ProgressViewScreen: View {
    private let mockDataService = MockDataService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Recovery Progress")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Track your activity and gait trends over time")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    DashboardCard(title: "Weekly Steps Trend") {
                        Label("Daily step count", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Chart(mockDataService.weeklySteps) { item in
                            LineMark(
                                x: .value("Day", item.day),
                                y: .value("Steps", item.steps)
                            )
                        }
                        .frame(height: 220)

                        Text("Mock weekly recovery trend")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    DashboardCard(title: "Walking Speed Trend") {
                        Label("Weekly walking speed", systemImage: "speedometer")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Chart(mockDataService.weeklyWalkingSpeed) { item in
                            LineMark(
                                x: .value("Day", item.day),
                                y: .value("Speed", item.speed)
                            )
                        }
                        .frame(height: 220)

                        Text("Mock weekly walking speed trend")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    DashboardCard(title: "Recovery Summary") {
                        Label("Overall progress", systemImage: "figure.walk")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Pre-op average: \(mockDataService.recoveryProgress.preOpAverageSteps) steps/day")
                        Text("Current average: \(mockDataService.recoveryProgress.currentAverageSteps) steps/day")

                        Text("\(mockDataService.recoveryProgress.recoveryPercentage)% of pre-op level")
                            .font(.title3)
                            .fontWeight(.bold)

                        ProgressView(
                            value: Double(mockDataService.recoveryProgress.recoveryPercentage),
                            total: 100
                        )
                    }

                    DashboardCard(title: "Adherence") {
                        Label("Data completeness", systemImage: "checkmark.circle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Recorded days: \(mockDataService.adherenceSummary.recordedDays) of \(mockDataService.adherenceSummary.totalDays)")
                            .font(.subheadline)

                        ProgressView(
                            value: Double(mockDataService.adherenceSummary.recordedDays),
                            total: Double(mockDataService.adherenceSummary.totalDays)
                        )

                        Text("\(mockDataService.adherenceSummary.percentage)% adherence this week")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    ProgressViewScreen()
}
