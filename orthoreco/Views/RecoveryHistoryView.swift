//
//  RecoveryHistoryView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 29/04/2026.
//

import SwiftUI
import Charts

struct RecoveryHistoryView: View {
    @State private var reports: [PatientReport] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var chartReports: [PatientReport] {
        reports.reversed()
    }
    
    private var riskResult: RiskIndicatorResult {
        RiskIndicatorCalculator.calculate(from: reports)
    }
    
    private func riskColor(_ level: String) -> Color {
        switch level {
        case "Low Risk":
            return .green
        case "Moderate Risk":
            return .orange
        case "High Risk":
            return .red
        default:
            return .gray
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading history...")
                } else if reports.isEmpty {
                    emptyState
                } else {
                    List {
                        Section("Risk Indicator") {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(riskResult.level)
                                        .font(.title3)
                                        .bold()

                                    Spacer()

                                    Text("\(riskResult.score)/100")
                                        .font(.headline)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(riskColor(riskResult.level).opacity(0.18))
                                        .foregroundStyle(riskColor(riskResult.level))
                                        .clipShape(Capsule())
                                }

                                Text(riskResult.message)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                        Section("Recovery Trend") {
                            Chart(chartReports) { report in
                                LineMark(
                                    x: .value("Date", report.reportDate),
                                    y: .value("Pain", report.painScore)
                                )
                                .foregroundStyle(by: .value("Metric", "Pain"))

                                LineMark(
                                    x: .value("Date", report.reportDate),
                                    y: .value("Walking Difficulty", report.walkingDifficulty)
                                )
                                .foregroundStyle(by: .value("Metric", "Walking"))

                                LineMark(
                                    x: .value("Date", report.reportDate),
                                    y: .value("Confidence", report.confidenceScore)
                                )
                                .foregroundStyle(by: .value("Metric", "Confidence"))
                            }
                            .frame(height: 240)
                            .padding(.vertical, 8)
                        }

                        Section("Check-In History") {
                            ForEach(reports) { report in
                                reportCard(report)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .task {
                await loadReports()
            }
            .onReceive(NotificationCenter.default.publisher(for: .reportSaved)) { _ in
                Task {
                    await loadReports()
                }
            }
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Recovery History")
                .font(.title2)
                .bold()

            Text("Your submitted recovery check-ins will appear here.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private func reportCard(_ report: PatientReport) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(report.reportDate)
                    .font(.headline)

                Spacer()

                Text(report.recoveryStatus)
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor(report.recoveryStatus).opacity(0.18))
                    .foregroundStyle(statusColor(report.recoveryStatus))
                    .clipShape(Capsule())
            }

            Text("Recovery Score: \(report.recoveryScore)/100")
                .font(.subheadline)
                .bold()

            Text(report.recoveryMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            HStack {
                Text("Pain: \(report.painScore)/10")
                Spacer()
                Text("Stiffness: \(report.stiffnessScore)/10")
            }

            HStack {
                Text("Walking: \(report.walkingDifficulty)/10")
                Spacer()
                Text("Confidence: \(report.confidenceScore)/10")
            }

            HStack {
                Text(report.swelling ? "Swelling: Yes" : "Swelling: No")
                Spacer()
                Text(report.exerciseCompleted ? "Exercise: Done" : "Exercise: Not Done")
            }

            if let notes = report.notes, !notes.isEmpty {
                Text("Notes: \(notes)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Good":
            return .green
        case "Moderate":
            return .orange
        default:
            return .red
        }
    }

    func loadReports() async {
        isLoading = true
        errorMessage = nil

        do {
            reports = try await ReportService.shared.fetchReports()
        } catch {
            errorMessage = "Could not load recovery history."
        }

        isLoading = false
    }
}

#Preview {
    RecoveryHistoryView()
}
