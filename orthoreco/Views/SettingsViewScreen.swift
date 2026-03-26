//
//  SettingsViewScreen.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 18/03/2026.
//

import SwiftUI

struct SettingsViewScreen: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    private let mockDataService = MockDataService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    DashboardCard(title: "Permissions") {
                        settingsRow(
                            title: "HealthKit",
                            value: "Not connected in simulator",
                            icon: "heart.text.square"
                        )

                        Text("HealthKit access can be tested later on a real iPhone.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    DashboardCard(title: "About") {
                        settingsRow(
                            title: "App",
                            value: "OrthoRecovery",
                            icon: "app.badge"
                        )

                        settingsRow(
                            title: "Mode",
                            value: "Research Prototype",
                            icon: "testtube.2"
                        )
                    }
                

                    Button(role: .destructive) {
                        AuthService.shared.logout()
                        isLoggedIn = false
                    } label: {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                }
                .padding()
            }
            .navigationTitle("Settings")
        }
    }

    private func settingsRow(title: String, value: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.body)
            }

            Spacer()
        }
    }
}

#Preview {
    SettingsViewScreen()
}
