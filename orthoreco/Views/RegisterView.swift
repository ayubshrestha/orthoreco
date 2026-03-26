//
//  RegisterView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegisterViewModel()
    @State private var showToast = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Register to begin monitoring your recovery progress.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                VStack(spacing: 16) {
                    TextField("First Name", text: $viewModel.firstName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    TextField("Last Name", text: $viewModel.lastName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender")
                            .font(.headline)

                        Picker("Gender", selection: $viewModel.gender) {
                            ForEach(viewModel.genders, id: \.self) { gender in
                                Text(gender).tag(gender)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    DatePicker(
                        "Date of Birth",
                        selection: $viewModel.dateOfBirth,
                        displayedComponents: .date
                    )
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

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

                    DatePicker(
                        "Surgery Date",
                        selection: $viewModel.surgeryDate,
                        displayedComponents: .date
                    )
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

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
                                showToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    showToast = false
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Register")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(viewModel.isLoading)

                    Button("Back to Login") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toast(isShowing: $showToast, message: "Registered successfully")
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
