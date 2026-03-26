//
//  HealthSyncViewModel.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 26/03/2026.
//

import Foundation
import Combine

@MainActor
final class HealthSyncViewModel: ObservableObject {
    @Published var isAuthorizing = false
    @Published var isSyncing = false
    @Published var errorMessage = ""
    @Published var lastSyncMessage = ""

    func requestAccess() async {
        errorMessage = ""
        isAuthorizing = true
        defer { isAuthorizing = false }

        do {
            try await HealthKitManager.shared.requestAuthorization()
            lastSyncMessage = "HealthKit access granted."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func syncToday() async -> Bool {
        errorMessage = ""
        lastSyncMessage = ""
        isSyncing = true
        defer { isSyncing = false }

        do {
            let summary = try await HealthKitManager.shared.fetchTodaySummary()
            try await AuthService.shared.createGaitRecordFromHealthKit(summary: summary)
            lastSyncMessage = "Today’s activity synced successfully."
            NotificationCenter.default.post(name: .dashboardShouldRefresh, object: nil)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func syncLast7Days() async -> Bool {
        errorMessage = ""
        lastSyncMessage = ""
        isSyncing = true
        defer { isSyncing = false }

        do {
            let summaries = try await HealthKitManager.shared.fetchRecentDailySummaries(days: 7)
            try await AuthService.shared.uploadHealthKitSummaries(summaries)
            lastSyncMessage = "Last 7 days synced successfully."
            NotificationCenter.default.post(name: .dashboardShouldRefresh, object: nil)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
