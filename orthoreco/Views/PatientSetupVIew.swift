//
//  PatientSetupView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 18/03/2026.
//

import SwiftUI

struct PatientSetupView: View {
    @Binding var hasCompletedSetup: Bool
    @StateObject private var viewModel = RegisterViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Patient Setup")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Create your account to begin monitoring recovery progress.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    VStack(spacing: 16) {
                        TextField("Patient ID", text: $viewModel.patientID)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Surgery Type")
                                .font(.headline)

                            Picker("Surgery Type", selection: $viewModel.surgeryType) {
                                ForEach(viewModel.surgeryTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Surgery Side")
                                .font(.headline)

                            Picker("Surgery Side", selection: $viewModel.surgerySide) {
                                ForEach(viewModel.surgerySides, id: \.self) { side in
                                    Text(side).tag(side)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            Task {
                                let success = await viewModel.register()
                                if success {
                                    hasCompletedSetup = true
                                }
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Complete Setup")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(viewModel.isLoading)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                    .padding(.horizontal)

                    Spacer(minLength: 24)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    PatientSetupView(hasCompletedSetup: .constant(false))
}
