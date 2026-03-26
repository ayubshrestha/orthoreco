//
//  WelcomeView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 18/03/2026.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var hasEnteredApp: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "figure.walk")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)

                Text("OrthoRecovery")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Research-grade gait and activity monitoring for orthopaedic recovery.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Continue") {
                    hasEnteredApp = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeView(hasEnteredApp: .constant(false))
}
