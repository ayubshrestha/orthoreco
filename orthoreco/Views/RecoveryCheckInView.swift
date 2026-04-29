//
//  RecoveryCheckInView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 29/04/2026.
//

import SwiftUI

struct RecoveryCheckInView: View {
    @StateObject private var viewModel = RecoveryCheckInViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Recovery Summary") {
                    Text("Score: \(viewModel.recoveryResult.score)/100")
                        .font(.title2)
                        .bold()

                    Text(viewModel.recoveryResult.status)
                        .font(.headline)

                    Text(viewModel.recoveryResult.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Symptoms") {
                    VStack(alignment: .leading) {
                        Text("Pain: \(Int(viewModel.painScore))/10")
                        Slider(value: $viewModel.painScore, in: 0...10, step: 1)
                    }

                    VStack(alignment: .leading) {
                        Text("Stiffness: \(Int(viewModel.stiffnessScore))/10")
                        Slider(value: $viewModel.stiffnessScore, in: 0...10, step: 1)
                    }

                    VStack(alignment: .leading) {
                        Text("Walking Difficulty: \(Int(viewModel.walkingDifficulty))/10")
                        Slider(value: $viewModel.walkingDifficulty, in: 0...10, step: 1)
                    }

                    VStack(alignment: .leading) {
                        Text("Walking Confidence: \(Int(viewModel.confidenceScore))/10")
                        Slider(value: $viewModel.confidenceScore, in: 0...10, step: 1)
                    }
                }

                Section("Daily Status") {
                    Toggle("Swelling noticed today", isOn: $viewModel.swelling)
                    Toggle("Completed exercises today", isOn: $viewModel.exerciseCompleted)
                }

                Section("Notes") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                }

                Section {
                    Button {
                        Task {
                            await viewModel.saveReport()
                        }
                    } label: {
                        if viewModel.isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save Check-In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .navigationTitle("Recovery Check-In")
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your recovery check-in has been saved and added to history.")
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    RecoveryCheckInView()
}
