//
//  HealthSyncView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 26/03/2026.
//

import SwiftUI

struct HealthSyncView: View {
    @StateObject private var viewModel = HealthSyncViewModel()
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.12),
                        Color(.systemGroupedBackground),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        actionsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("HealthKit Sync")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .toast(isShowing: $showToast, message: toastMessage)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sync activity from Health")
                .font(.system(size: 28, weight: .bold))

            Text("Import step count, walking distance, and walking speed from Apple Health into your recovery dashboard.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("HealthKit Access")

            VStack(spacing: 14) {
                Button {
                    Task {
                        await viewModel.requestAccess()
                        if !viewModel.lastSyncMessage.isEmpty {
                            show(message: viewModel.lastSyncMessage)
                        }
                    }
                } label: {
                    if viewModel.isAuthorizing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Grant Health Access")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button {
                    Task {
                        let success = await viewModel.syncToday()
                        if success {
                            show(message: "Today’s Health data synced")
                        }
                    }
                } label: {
                    if viewModel.isSyncing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Sync Today")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button {
                    Task {
                        let success = await viewModel.syncLast7Days()
                        if success {
                            show(message: "Last 7 days synced")
                        }
                    }
                } label: {
                    if viewModel.isSyncing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Sync Last 7 Days")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !viewModel.lastSyncMessage.isEmpty {
                    Text(viewModel.lastSyncMessage)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(18)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }

    private func show(message: String) {
        toastMessage = message
        showToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showToast = false
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HealthSyncView()
}
