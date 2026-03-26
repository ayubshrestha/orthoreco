//
//  ConsentView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 18/03/2026.
//

import SwiftUI

struct ConsentView: View {
    @Binding var hasConsented: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Research Consent")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Please review the following before continuing.")
                        .foregroundStyle(.secondary)

                    DashboardCard(title: "Study Purpose") {
                        Text("This app collects gait and activity data to support orthopaedic recovery monitoring and research.")
                    }

                    DashboardCard(title: "What Data Is Collected") {
                        Text("Step count, walking speed, recovery trends, and questionnaire responses may be collected.")
                    }

                    DashboardCard(title: "Privacy") {
                        Text("Your research data should be stored securely and used only for approved clinical or research purposes.")
                    }

                    Button("I Agree and Continue") {
                        hasConsented = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ConsentView(hasConsented: .constant(false))
}
