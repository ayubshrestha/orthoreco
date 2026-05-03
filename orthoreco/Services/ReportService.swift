//
//  ReportService.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 29/04/2026.
//

import Foundation

final class ReportService {
    static let shared = ReportService()
    private init() {}

    private let baseURL = "http://127.0.0.1:8000"

    func submitReport(request: [String: Any]) async throws {
        guard let url = URL(string: "\(baseURL)/reports/") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "authToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        req.httpBody = try JSONSerialization.data(withJSONObject: request)

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200...299 ~= http.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "Server error"
            print("Submit report failed:", message)
            throw URLError(.badServerResponse)
        }
    }

    func fetchReports() async throws -> [PatientReport] {
        guard let url = URL(string: "\(baseURL)/reports/me") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "authToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200...299 ~= http.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "Server error"
            print("Fetch reports failed:", message)
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([PatientReport].self, from: data)
    }
    
    func fetchWeeklySummary() async throws -> WeeklyRecoverySummary {
        guard let url = URL(string: "\(baseURL)/reports/me/weekly-summary") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "authToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200...299 ~= http.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "Server error"
            print("Fetch weekly summary failed:", message)
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(WeeklyRecoverySummary.self, from: data)
    }
}
