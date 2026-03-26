//
//  MyAccountView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import SwiftUI

struct MyAccountView: View {
    @StateObject private var viewModel = ProfileViewModel()

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
                    if viewModel.isLoading {
                        loadingView
                    } else if let user = viewModel.user {
                        profileContent(user)
                    } else if !viewModel.errorMessage.isEmpty {
                        errorView
                    } else {
                        emptyStateView
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Account")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .task {
                await viewModel.fetchProfile()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Loading your profile...")
                .foregroundColor(.secondary)
        }
    }

    private var errorView: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 42))
                .foregroundColor(.orange)

            Text("Could not load profile")
                .font(.headline)

            Text(viewModel.errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.fetchProfile()
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
            Image(systemName: "person.crop.circle")
                .font(.system(size: 44))
                .foregroundColor(.blue)

            Text("No profile data available")
                .font(.headline)

            Text("Your account information will appear here after login.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 20)
    }

    private func profileContent(_ user: UserResponse) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader(user)

                personalDetailsSection(user)

                accountDetailsSection(user)

                surgeryDetailsSection(user)

                if let createdAt = user.created_at {
                    accountMetaSection(createdAt)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }

    private func profileHeader(_ user: UserResponse) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)

                Text(initials(for: user))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text("\(user.first_name) \(user.last_name)")
                    .font(.system(size: 26, weight: .bold))

                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                profilePill(icon: "person.text.rectangle", title: user.patient_id)
                profilePill(icon: "person.fill", title: user.gender)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func personalDetailsSection(_ user: UserResponse) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Personal Details")

            infoCard {
                infoRow(label: "First Name", value: user.first_name)
                divider
                infoRow(label: "Last Name", value: user.last_name)
                divider
                infoRow(label: "Gender", value: user.gender)
                divider
                infoRow(label: "Date of Birth", value: user.date_of_birth ?? "Not provided")
            }
        }
    }

    private func accountDetailsSection(_ user: UserResponse) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Account Details")

            infoCard {
                infoRow(label: "Patient ID", value: user.patient_id)
                divider
                infoRow(label: "Email", value: user.email)
                divider
                infoRow(label: "Role", value: user.role ?? "patient")
            }
        }
    }

    private func surgeryDetailsSection(_ user: UserResponse) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Surgery Details")

            infoCard {
                infoRow(label: "Surgery Type", value: user.surgery_type)
                divider
                infoRow(label: "Surgery Side", value: user.surgery_side)
                divider
                infoRow(label: "Surgery Date", value: user.surgery_date ?? "Not provided")
            }
        }
    }

    private func accountMetaSection(_ createdAt: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Account")

            infoCard {
                infoRow(label: "Created At", value: createdAt)
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func profilePill(icon: String, title: String) -> some View {
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

    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
    }

    private var divider: some View {
        Divider()
            .overlay(Color.white.opacity(0.45))
    }

    private func initials(for user: UserResponse) -> String {
        let first = user.first_name.first.map(String.init) ?? ""
        let last = user.last_name.first.map(String.init) ?? ""
        return "\(first)\(last)"
    }
}

#Preview {
    MyAccountView()
}
