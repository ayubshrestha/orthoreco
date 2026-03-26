//
//  PatientDashboardResponse.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation

struct PatientDashboardResponse: Codable {
    let patient_id: String
    let surgery_type: String
    let surgery_side: String
    let total_records: Int
    let latest_record: GaitRecordResponse?
    let average_step_count: Double
    let average_walking_speed: Double?
    let average_cadence: Double?
}

struct GaitRecordResponse: Codable {
    let id: Int
    let user_id: Int
    let record_date: String
    let step_count: Int
    let walking_speed: Double?
    let cadence: Double?
    let distance: Double?
    let active_minutes: Int?
    let created_at: String
}
