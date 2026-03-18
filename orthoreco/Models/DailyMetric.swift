//
//  DailyMetric.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 16/03/2026.
//

import Foundation

struct DailyMetric: Identifiable {
    let id = UUID()
    let day: String
    let steps: Int
}
