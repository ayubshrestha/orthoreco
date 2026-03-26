//
//  HealthKitManager.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 16/03/2026.
//

import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    private init() {}

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(
                domain: "HealthKit",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device."]
            )
        }

        guard
            let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            let walkingSpeedType = HKObjectType.quantityType(forIdentifier: .walkingSpeed)
        else {
            throw NSError(
                domain: "HealthKit",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Required HealthKit data types are unavailable."]
            )
        }

        let readTypes: Set<HKObjectType> = [
            stepType,
            distanceType,
            walkingSpeedType
        ]

        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }

    func fetchTodaySummary() async throws -> HealthSummary {
        async let steps = fetchTodayStepCount()
        async let distance = fetchTodayWalkingRunningDistance()
        async let walkingSpeed = fetchTodayAverageWalkingSpeed()

        return try await HealthSummary(
            recordDate: Self.dateString(from: Date()),
            stepCount: steps,
            distance: distance,
            walkingSpeed: walkingSpeed
        )
    }

    func fetchRecentDailySummaries(days: Int = 7) async throws -> [HealthSummary] {
        guard days > 0 else { return [] }

        var summaries: [HealthSummary] = []

        for offset in 0..<days {
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) else {
                continue
            }

            async let steps = fetchStepCount(for: date)
            async let distance = fetchWalkingRunningDistance(for: date)
            async let walkingSpeed = fetchAverageWalkingSpeed(for: date)

            let summary = try await HealthSummary(
                recordDate: Self.dateString(from: date),
                stepCount: steps,
                distance: distance,
                walkingSpeed: walkingSpeed
            )

            summaries.append(summary)
        }

        return summaries.sorted { $0.recordDate < $1.recordDate }
    }

    private func fetchTodayStepCount() async throws -> Int {
        try await fetchStepCount(for: Date())
    }

    private func fetchTodayWalkingRunningDistance() async throws -> Double? {
        try await fetchWalkingRunningDistance(for: Date())
    }

    private func fetchTodayAverageWalkingSpeed() async throws -> Double? {
        try await fetchAverageWalkingSpeed(for: Date())
    }

    private func fetchStepCount(for date: Date) async throws -> Int {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            throw NSError(domain: "HealthKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "Step count type unavailable."])
        }

        let predicate = predicateForDay(date)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let value = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(value))
            }

            healthStore.execute(query)
        }
    }

    private func fetchWalkingRunningDistance(for date: Date) async throws -> Double? {
        guard let type = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return nil
        }

        let predicate = predicateForDay(date)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let meters = result?.sumQuantity()?.doubleValue(for: HKUnit.meter())
                let kilometers = meters.map { $0 / 1000.0 }
                continuation.resume(returning: kilometers)
            }

            healthStore.execute(query)
        }
    }

    private func fetchAverageWalkingSpeed(for date: Date) async throws -> Double? {
        guard let type = HKObjectType.quantityType(forIdentifier: .walkingSpeed) else {
            return nil
        }

        let predicate = predicateForDay(date)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let speed = result?.averageQuantity()?.doubleValue(
                    for: HKUnit.meter().unitDivided(by: .second())
                )
                continuation.resume(returning: speed)
            }

            healthStore.execute(query)
        }
    }

    private func predicateForDay(_ date: Date) -> NSPredicate {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date

        return HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )
    }

    private static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct HealthSummary {
    let recordDate: String
    let stepCount: Int
    let distance: Double?
    let walkingSpeed: Double?
}
