//
//  LoginResponse.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import Foundation

struct LoginResponse: Codable {
    let access_token: String
    let token_type: String
}
