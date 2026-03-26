//
//  AdherenceSummary.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 18/03/2026.
//

import Foundation

struct AdherenceSummary {
    let recordedDays: Int
    let totalDays: Int

    var percentage: Int {
        Int((Double(recordedDays) / Double(totalDays)) * 100)
    }
}
