//
//  ContentView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 16/03/2026.
//

import SwiftUI
import Charts

struct ContentView: View {
    private let healthKitManager = HealthKitManager.shared
    private let mockDataService = MockDataService()

    @State private var statusMessage = "Tap the button to request HealthKit access"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("OrthoReco")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Day \(mockDataService.patientProfile.daysSinceSurgery) after surgery • \(mockDataService.recoveryProgress.recoveryPercentage)% recovered")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    DashboardCard(title: "Daily Goal") {
                        Label("Step target", systemImage: "target")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Goal: \(mockDataService.dailyStepGoal) steps")
                            .font(.subheadline)

                        Text("Completed: \(mockDataService.todaySteps) steps")
                            .font(.subheadline)

                        ProgressView(
                            value: Double(mockDataService.todaySteps),
                            total: Double(mockDataService.dailyStepGoal)
                        )

                        let goalPercent = Int((Double(mockDataService.todaySteps) / Double(mockDataService.dailyStepGoal)) * 100)
                        Text("\(goalPercent)% of daily goal")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    DashboardCard(title: "Recovery Status") {
                        Label("Current status", systemImage: "heart.text.square")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        let recovery = mockDataService.recoveryProgress.recoveryPercentage

                        Text(statusText(for: recovery))
                            .font(.title3)
                            .fontWeight(.bold)

                        Text(statusDescription(for: recovery))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    DashboardCard(title: "Recovery Overview") {
                        Label("Recovery level", systemImage: "figure.walk")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("\(mockDataService.recoveryProgress.recoveryPercentage)%")
                            .font(.system(size: 44, weight: .bold))

                        Text("Recovered compared with pre-operative activity")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ProgressView(
                            value: Double(mockDataService.recoveryProgress.recoveryPercentage),
                            total: 100
                        )

                        Text("Day \(mockDataService.patientProfile.daysSinceSurgery) after \(mockDataService.patientProfile.surgeryType)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        DashboardCard(title: "Steps") {
                            Label("Today", systemImage: "shoeprints.fill")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Text("\(mockDataService.todaySteps)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        DashboardCard(title: "Speed") {
                            Label("Walking speed", systemImage: "speedometer")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Text("\(mockDataService.walkingSpeed, specifier: "%.2f") m/s")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }

                    DashboardCard(title: "Health Access") {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)

                        Button("Request Step Count Access") {
                            requestHealthAccess()
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Spacer()
                }.frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    private func requestHealthAccess() {
        #if targetEnvironment(simulator)
        statusMessage = "HealthKit permission cannot be tested in the iOS Simulator. Use a real iPhone later."
        return
        #else
        guard healthKitManager.isHealthDataAvailable() else {
            statusMessage = "Health data is not available on this device."
            return
        }

        healthKitManager.requestAuthorization { success, error in
            if success {
                statusMessage = "HealthKit access granted."
            } else if let error = error {
                statusMessage = "Access failed: \(error.localizedDescription)"
            } else {
                statusMessage = "HealthKit access was not granted."
            }
        }
        #endif
    }
    
    private func statusText(for recovery: Int) -> String {
        if recovery >= 80 {
            return "Improving well"
        } else if recovery >= 50 {
            return "On track"
        } else {
            return "Needs attention"
        }
    }

    private func statusDescription(for recovery: Int) -> String {
        if recovery >= 80 {
            return "Your activity level is close to your pre-operative baseline."
        } else if recovery >= 50 {
            return "Your recovery is progressing steadily."
        } else {
            return "Your activity level is still well below baseline."
        }
    }
}

#Preview {
    ContentView()
}
