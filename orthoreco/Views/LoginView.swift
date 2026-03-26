//
//  LoginView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @State private var showToast = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)

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

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task {
                        let success = await viewModel.login()
                        if success {
                            showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showToast = false
                                isLoggedIn = true
                            }
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(viewModel.isLoading)

                NavigationLink("Create Account", destination: RegisterView())
                    .padding(.top, 8)

                Spacer()
            }
            .padding()
            .toast(isShowing: $showToast, message: "Logged in successfully")
        }
    }
}

#Preview {
    LoginView()
}
