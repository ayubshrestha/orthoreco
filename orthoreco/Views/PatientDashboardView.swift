//
//  PatientDashboardView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import SwiftUI
import Charts

struct PatientDashboardView: View {
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @StateObject private var recordsViewModel = RecordsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.12),
                        Color(.systemGroupedBackground),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                Group {
                    if dashboardViewModel.isLoading {
                        loadingView
                    } else if let dashboard = dashboardViewModel.dashboard {
                        dashboardContent(dashboard)
                    } else if !dashboardViewModel.errorMessage.isEmpty {
                        errorView
                    } else {
                        emptyStateView
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Recovery Dashboard")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .task {
                await loadAllData()
            }
            .onReceive(NotificationCenter.default.publisher(for: .dashboardShouldRefresh)) { _ in
                Task {
                    await loadAllData()
                }
            }
        }
    }

    private func loadAllData() async {
        await dashboardViewModel.fetchDashboard()
        await recordsViewModel.fetchRecords()
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Loading your dashboard...")
                .foregroundColor(.secondary)
        }
    }

    private var errorView: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42))
                .foregroundColor(.orange)

            Text("Could not load dashboard")
                .font(.headline)

            Text(dashboardViewModel.errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await loadAllData()
                }
            } label: {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 20)
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "figure.walk")
                .font(.system(size: 44))
                .foregroundColor(.blue)

            Text("No dashboard data yet")
                .font(.headline)

            Text("Your recovery insights will appear here once activity records are available.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 20)
    }

    private func dashboardContent(_ dashboard: PatientDashboardResponse) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection(dashboard)
                summarySection(dashboard)
                averagesSection(dashboard)
                trendsSection
                latestRecordSection(dashboard.latest_record)
                recentRecordsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .refreshable {
            await loadAllData()
        }
    }
    
    private func headerSection(_ dashboard: PatientDashboardResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome back")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Track your recovery progress")
                .font(.system(size: 28, weight: .bold))

            HStack(spacing: 12) {
                dashboardPill(icon: "person.text.rectangle", title: dashboard.patient_id)
                dashboardPill(icon: "cross.case", title: dashboard.surgery_type)
                dashboardPill(icon: "arrow.left.and.right.righttriangle.left.righttriangle.right", title: dashboard.surgery_side)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func summarySection(_ dashboard: PatientDashboardResponse) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Overview")

            HStack(spacing: 12) {
                statCard(
                    title: "Records",
                    value: "\(dashboard.total_records)",
                    subtitle: "Total submissions",
                    icon: "calendar.badge.clock"
                )

                statCard(
                    title: "Average Steps",
                    value: "\(Int(dashboard.average_step_count))",
                    subtitle: "Per record",
                    icon: "figure.walk.motion"
                )
            }
        }
    }

    private func averagesSection(_ dashboard: PatientDashboardResponse) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Average Metrics")

            VStack(spacing: 12) {
                metricRowCard(
                    title: "Walking Speed",
                    value: dashboard.average_walking_speed != nil
                        ? String(format: "%.2f m/s", dashboard.average_walking_speed!)
                        : "N/A",
                    icon: "speedometer"
                )

                metricRowCard(
                    title: "Cadence",
                    value: dashboard.average_cadence != nil
                        ? String(format: "%.2f steps/min", dashboard.average_cadence!)
                        : "N/A",
                    icon: "waveform.path.ecg"
                )
            }
        }
    }

    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Step Count Trend")

            if recordsViewModel.sortedAscendingRecords.isEmpty {
                emptyCard(title: "Trend", message: "Add more records to see your recovery trend over time.")
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Chart(recordsViewModel.sortedAscendingRecords, id: \.id) { record in
                        LineMark(
                            x: .value("Date", record.record_date),
                            y: .value("Steps", record.step_count)
                        )
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Date", record.record_date),
                            y: .value("Steps", record.step_count)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.blue.opacity(0.12))

                        PointMark(
                            x: .value("Date", record.record_date),
                            y: .value("Steps", record.step_count)
                        )
                    }
                    .frame(height: 220)

                    Text("Daily step count progression across submitted records")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(18)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
        }
    }

    private func latestRecordSection(_ record: GaitRecordResponse?) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Latest Record")

            if let record {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.record_date)
                                .font(.headline)
                            Text("Most recent activity entry")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        miniMetricCard(title: "Steps", value: "\(record.step_count)", icon: "shoeprints.fill")
                        miniMetricCard(
                            title: "Speed",
                            value: record.walking_speed != nil ? String(format: "%.2f", record.walking_speed!) : "N/A",
                            icon: "speedometer"
                        )
                        miniMetricCard(
                            title: "Cadence",
                            value: record.cadence != nil ? String(format: "%.2f", record.cadence!) : "N/A",
                            icon: "waveform.path.ecg"
                        )
                        miniMetricCard(
                            title: "Distance",
                            value: record.distance != nil ? String(format: "%.2f km", record.distance!) : "N/A",
                            icon: "location.fill"
                        )
                        miniMetricCard(
                            title: "Active Minutes",
                            value: record.active_minutes != nil ? "\(record.active_minutes!)" : "N/A",
                            icon: "timer"
                        )
                    }
                }
                .padding(18)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            } else {
                emptyCard(title: "Latest Record", message: "No latest record available yet.")
            }
        }
    }

    private var recentRecordsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Recent Records")

            if recordsViewModel.recentRecords.isEmpty {
                emptyCard(title: "Recent Records", message: "Your submitted activity history will appear here.")
            } else {
                VStack(spacing: 12) {
                    ForEach(recordsViewModel.recentRecords, id: \.id) { record in
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.blue.opacity(0.12))
                                    .frame(width: 46, height: 46)

                                Image(systemName: "figure.walk")
                                    .foregroundColor(.blue)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(record.record_date)
                                    .font(.headline)

                                Text("Steps: \(record.step_count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 12) {
                                    if let speed = record.walking_speed {
                                        Text("Speed: \(String(format: "%.2f", speed))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    if let cadence = record.cadence {
                                        Text("Cadence: \(String(format: "%.2f", cadence))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(18)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dashboardPill(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.8))
        .clipShape(Capsule())
    }

    private func statCard(title: String, value: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Spacer()
            }

            Text(value)
                .font(.system(size: 26, weight: .bold))

            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private func metricRowCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text("Average across available records")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private func miniMetricCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    


    @ViewBuilder
    private func emptyCard(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Text(message)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    }

#Preview {
    PatientDashboardView()
}
