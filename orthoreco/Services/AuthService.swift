import Foundation

final class AuthService {
    static let shared = AuthService()

    private let baseURL = "http://127.0.0.1:8000"

    private init() {}

    func register(
        firstName: String,
        lastName: String,
        gender: String,
        dateOfBirth: String?,
        patientID: String,
        email: String,
        password: String,
        surgeryType: String,
        surgerySide: String,
        surgeryDate: String?
    ) async throws {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw URLError(.badURL)
        }

        let payload = RegisterRequest(
            first_name: firstName,
            last_name: lastName,
            gender: gender,
            date_of_birth: dateOfBirth,
            patient_id: patientID,
            email: email,
            password: password,
            surgery_type: surgeryType,
            surgery_side: surgerySide,
            surgery_date: surgeryDate
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Registration failed"
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: serverMessage
            ])
        }
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let bodyString = "username=\(percentEncode(email))&password=\(percentEncode(password))"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Login failed"
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: serverMessage
            ])
        }

        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }

    func getCurrentUser() async throws -> UserResponse {
        guard let url = URL(string: "\(baseURL)/auth/me") else {
            throw URLError(.badURL)
        }

        guard let token = TokenManager.shared.getToken() else {
            throw NSError(domain: "", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "No auth token found"
            ])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Could not fetch profile"
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: serverMessage
            ])
        }

        return try JSONDecoder().decode(UserResponse.self, from: data)
    }

    func logout() {
        TokenManager.shared.clearToken()
    }
    
    func getPatientDashboard() async throws -> PatientDashboardResponse {
        guard let url = URL(string: "\(baseURL)/dashboard/patient") else {
            throw URLError(.badURL)
        }

        guard let token = TokenManager.shared.getToken() else {
            throw NSError(
                domain: "",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No auth token found"]
            )
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Could not fetch dashboard"
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: serverMessage]
            )
        }

        return try JSONDecoder().decode(PatientDashboardResponse.self, from: data)
    }
    
    func createGaitRecord(
        recordDate: String,
        stepCount: Int,
        walkingSpeed: Double?,
        cadence: Double?,
        distance: Double?,
        activeMinutes: Int?
    ) async throws {
        guard let url = URL(string: "\(baseURL)/gait-data/") else {
            throw URLError(.badURL)
        }

        guard let token = TokenManager.shared.getToken(), !token.isEmpty else {
            print("DEBUG: No auth token found before gait record request")
            throw NSError(
                domain: "",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No auth token found"]
            )
        }

        print("DEBUG: Sending gait record with token: \(token.prefix(20))...")

        let payload = GaitRecordCreateRequest(
            record_date: recordDate,
            step_count: stepCount,
            walking_speed: walkingSpeed!,
            cadence: cadence!,
            distance: distance!,
            active_minutes: activeMinutes
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("DEBUG: gait-data status =", httpResponse.statusCode)
        print("DEBUG: gait-data response =", String(data: data, encoding: .utf8) ?? "nil")

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Could not save gait record"
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: serverMessage]
            )
        }
    }
    
    func getMyGaitRecords() async throws -> [GaitRecordResponse] {
        guard let url = URL(string: "\(baseURL)/gait-data/") else {
            throw URLError(.badURL)
        }

        guard let token = TokenManager.shared.getToken(), !token.isEmpty else {
            throw NSError(
                domain: "",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No auth token found"]
            )
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Could not fetch gait records"
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: serverMessage]
            )
        }

        return try JSONDecoder().decode([GaitRecordResponse].self, from: data)
    }
    
    func createGaitRecordFromHealthKit(summary: HealthSummary) async throws {
        try await createGaitRecord(
            recordDate: summary.recordDate,
            stepCount: summary.stepCount,
            walkingSpeed: summary.walkingSpeed,
            cadence: nil,
            distance: summary.distance,
            activeMinutes: nil
        )
    }
    
    func uploadHealthKitSummaries(_ summaries: [HealthSummary]) async throws {
        for summary in summaries {
            try await createGaitRecordFromHealthKit(summary: summary)
        }
    }

    private func percentEncode(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
}
