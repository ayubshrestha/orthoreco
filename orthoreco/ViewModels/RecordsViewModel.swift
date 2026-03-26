//
//  RecordsViewModel.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation
import Combine

@MainActor
final class RecordsViewModel: ObservableObject {
    @Published var records: [GaitRecordResponse] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    func fetchRecords() async {
        isLoading = true
        errorMessage = ""

        do {
            records = try await AuthService.shared.getMyGaitRecords()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    var sortedAscendingRecords: [GaitRecordResponse] {
        records.sorted { $0.record_date < $1.record_date }
    }

    var recentRecords: [GaitRecordResponse] {
        Array(records.prefix(5))
    }
}
