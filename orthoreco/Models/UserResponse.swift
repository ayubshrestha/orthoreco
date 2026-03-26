//
//  UserResponse.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation

struct UserResponse: Codable {
    let id: Int
    let first_name: String
    let last_name: String
    let gender: String
    let date_of_birth: String?

    let patient_id: String
    let email: String

    let surgery_type: String
    let surgery_side: String
    let surgery_date: String?

    let role: String?
    let created_at: String?
}
