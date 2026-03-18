//
//  ContentView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 16/03/2026.
//

import SwiftUI
import Charts

struct ContentView: View {
    private let healthKitManager = HealthKitManager()
    private let mockDataService = MockDataService()

    @State private var statusMessage = "Tap the button to request HealthKit access"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("OrthoRecovery")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Gait and activity monitoring")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    DashboardCard(title: "Today's Steps") {
                        Text("\(mockDataService.todaySteps)")
                            .font(.system(size: 40, weight: .bold))

                        Text("Mock data for simulator")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    DashboardCard(title: "Walking Speed") {
                        Text("\(mockDataService.walkingSpeed, specifier: "%.2f") m/s")
                            .font(.system(size: 32, weight: .bold))

                        Text("Mock gait metric")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    DashboardCard(title: "Recovery Progress") {
                        Text("Pre-op average: \(mockDataService.recoveryProgress.preOpAverageSteps) steps/day")
                            .font(.subheadline)

                        Text("Current average: \(mockDataService.recoveryProgress.currentAverageSteps) steps/day")
                            .font(.subheadline)

                        Text("\(mockDataService.recoveryProgress.recoveryPercentage)% of pre-op level")
                            .font(.title3)
                            .fontWeight(.bold)

                        ProgressView(value: Double(mockDataService.recoveryProgress.recoveryPercentage), total: 100)
                    }

                    DashboardCard(title: "Weekly Recovery Trend") {
                        Chart(mockDataService.weeklySteps) { item in
                            LineMark(
                                x: .value("Day", item.day),
                                y: .value("Steps", item.steps)
                            )
                        }
                        .frame(height: 220)

                        Text("Mock weekly step trend")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
                }
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
}

#Preview {
    ContentView()
}
