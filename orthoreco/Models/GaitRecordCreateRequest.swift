//
//  GaitRecordCreateRequest.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation

struct GaitRecordCreateRequest: Codable {
    let record_date: String
    let step_count: Int
    let walking_speed: Double
    let cadence: Double
    let distance: Double
    let active_minutes: Int?
}
