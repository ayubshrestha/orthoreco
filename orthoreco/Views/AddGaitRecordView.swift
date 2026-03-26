//
//  AddGaitRecordView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import SwiftUI

struct AddGaitRecordView: View {
    @StateObject private var viewModel = AddGaitRecordViewModel()
    @State private var showToast = false

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

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        formSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Activity Record")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .toast(isShowing: $showToast, message: "Record saved successfully")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Record your recovery activity")
                .font(.system(size: 28, weight: .bold))

            Text("Enter your daily gait and activity metrics to track recovery progress over time.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Activity Details")

            VStack(spacing: 14) {
                DatePicker(
                    "Record Date",
                    selection: $viewModel.recordDate,
                    displayedComponents: .date
                )
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                inputField("Step Count", text: $viewModel.stepCount, keyboardType: .numberPad)
                inputField("Walking Speed (m/s)", text: $viewModel.walkingSpeed, keyboardType: .decimalPad)
                inputField("Cadence (steps/min)", text: $viewModel.cadence, keyboardType: .decimalPad)
                inputField("Distance (km)", text: $viewModel.distance, keyboardType: .decimalPad)
                inputField("Active Minutes", text: $viewModel.activeMinutes, keyboardType: .numberPad)

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task {
                        let success = await viewModel.saveRecord()
                        if success {
                            showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                showToast = false
                            }
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Save Record")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(viewModel.isLoading)
            }
            .padding(18)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func inputField(_ title: String, text: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            TextField(title, text: text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview {
    AddGaitRecordView()
}
