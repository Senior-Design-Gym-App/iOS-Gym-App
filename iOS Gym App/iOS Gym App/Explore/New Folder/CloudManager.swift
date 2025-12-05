//
//  CloudManager.swift
//  iOS Gym App
//
//  AWS Cognito + API Gateway Integration
//

import Foundation
import SwiftData

@MainActor
class CloudManager{
    static let shared = CloudManager()
    
    // MARK: - Configuration
    private let apiBaseURL: String
    
    // Reference to AuthManager for authentication
    private weak var authManager: AuthManager?
    
    private init() {
        // Get API URL from config
        self.apiBaseURL = CognitoConfig.apiBaseUrl
    }
    
    /// Set the auth manager reference
    func setAuthManager(_ manager: AuthManager) {
        self.authManager = manager
    }
    
    // MARK: - Token Management
    
    /// Get current ID token from Keychain
    private func getIdToken() -> String? {
        return KeychainHelper.standard.retrieveToken(key: "idToken")
    }
    
    /// Get current access token from Keychain
    private func getAccessToken() -> String? {
        return KeychainHelper.standard.retrieveToken(key: "accessToken")
    }
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        return authManager?.isAuthenticated ?? false
    }
    
    // MARK: - API Methods
    
    /// Fetch public workouts from the API
    func fetchPublicWorkouts(tags: [String]? = nil) async throws -> [Workout] {
        guard isAuthenticated else {
            throw CloudError.notAuthenticated
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        
        print("✅ Found ID token for API request")
        
        var endpoint = "/workouts/public"
        
        // Add tags query parameter if provided
        if let tags = tags, !tags.isEmpty {
            let tagsParam = tags.joined(separator: ",")
            endpoint += "?tags=\(tagsParam.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        let url = apiBaseURL + endpoint
        
        let headers = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let response = try await makeRequest(
            url: url,
            method: "GET",
            headers: headers,
            body: nil
        )
        
        guard let workoutsArray = response["workouts"] as? [[String: Any]] else {
            throw CloudError.invalidResponse
        }
        
        return try workoutsArray.compactMap { try? parseWorkout(from: $0) }
    }
    
    /// Fetch user's workouts
    func fetchMyWorkouts() async throws -> [Workout] {
        guard isAuthenticated else {
            throw CloudError.notAuthenticated
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        
        let endpoint = "/workouts"
        let url = apiBaseURL + endpoint
        
        let headers = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let response = try await makeRequest(
            url: url,
            method: "GET",
            headers: headers,
            body: nil
        )
        
        guard let workoutsArray = response["workouts"] as? [[String: Any]] else {
            throw CloudError.invalidResponse
        }
        
        return try workoutsArray.compactMap { try? parseWorkout(from: $0) }
    }
    
    /// Get a specific workout by ID
    func fetchWorkout(workoutId: String) async throws -> Workout {
        guard isAuthenticated else {
            throw CloudError.notAuthenticated
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        
        let endpoint = "/workouts/\(workoutId)"
        let url = apiBaseURL + endpoint
        
        let headers = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let response = try await makeRequest(
            url: url,
            method: "GET",
            headers: headers,
            body: nil
        )
        
        return try parseWorkout(from: response)
    }
    
    /// Create a new workout
    func createWorkout(_ workout: Workout) async throws -> String {
        guard isAuthenticated else {
            throw CloudError.notAuthenticated
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        
        let endpoint = "/workouts"
        let url = apiBaseURL + endpoint
        
        let headers = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let body = try serializeWorkout(workout)
        
        let response = try await makeRequest(
            url: url,
            method: "POST",
            headers: headers,
            body: body
        )
        
        guard let workoutId = response["workoutId"] as? String else {
            throw CloudError.invalidResponse
        }
        
        return workoutId
    }
    
    /// Update an existing workout
    func updateWorkout(workoutId: String, workout: Workout) async throws {
        guard isAuthenticated else {
            throw CloudError.notAuthenticated
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        
        let endpoint = "/workouts/\(workoutId)"
        let url = apiBaseURL + endpoint
        
        let headers = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let body = try serializeWorkout(workout)
        
        _ = try await makeRequest(
            url: url,
            method: "PUT",
            headers: headers,
            body: body
        )
    }
    
    /// Delete a workout
    func deleteWorkout(workoutId: String) async throws {
        guard isAuthenticated else {
            throw CloudError.notAuthenticated
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        
        let endpoint = "/workouts/\(workoutId)"
        let url = apiBaseURL + endpoint
        
        let headers = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        _ = try await makeRequest(
            url: url,
            method: "DELETE",
            headers: headers,
            body: nil
        )
    }
    
    /// Publish a workout (make it public)
    func publishWorkout(workoutId: String) async throws {
        guard isAuthenticated else {
            throw CloudError.notAuthenticated
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        
        let endpoint = "/workouts/\(workoutId)/publish"
        let url = apiBaseURL + endpoint
        
        let headers = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        _ = try await makeRequest(
            url: url,
            method: "POST",
            headers: headers,
            body: nil
        )
    }
    
    /// Copy a public workout to user's account
    func copyWorkout(workoutId: String) async throws -> String {
        guard isAuthenticated else {
            throw CloudError.notAuthenticated
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        
        let endpoint = "/workouts/\(workoutId)/copy"
        let url = apiBaseURL + endpoint
        
        let headers = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let response = try await makeRequest(
            url: url,
            method: "POST",
            headers: headers,
            body: nil
        )
        
        guard let newWorkoutId = response["workoutId"] as? String else {
            throw CloudError.invalidResponse
        }
        
        return newWorkoutId
    }
    
    /// Get current user info
    func getCurrentUser() -> [String: String]? {
        return authManager?.userAttributes
    }
    
    /// Get user's email
    func getUserEmail() -> String? {
        return authManager?.currentUser
    }
    
    // MARK: - Helper Methods
    
    private func makeRequest(
        url: String,
        method: String,
        headers: [String: String],
        body: [String: Any]?
    ) async throws -> [String: Any] {
        guard let requestURL = URL(string: url) else {
            throw CloudError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        print("🌐 API Request: \(method) \(url)")
        if let body = body {
            print("📤 Body: \(body)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudError.invalidResponse
        }
        
        print("📥 Response Status: \(httpResponse.statusCode)")
        
        // Handle 401 Unauthorized - token might be expired
        if httpResponse.statusCode == 401 {
            print("⚠️ Unauthorized - token may be expired")
            throw CloudError.tokenExpired
        }
        
        // Parse JSON response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                // Success with no body
                return [:]
            }
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Response: \(errorString)")
            }
            throw CloudError.invalidResponse
        }
        
        // Check for errors
        if httpResponse.statusCode >= 400 {
            if let message = json["message"] as? String {
                throw CloudError.serverError(message)
            }
            throw CloudError.serverError("HTTP \(httpResponse.statusCode)")
        }
        
        return json
    }
    
    private func parseWorkout(from dict: [String: Any]) throws -> Workout {
        guard let name = dict["name"] as? String else {
            throw CloudError.invalidResponse
        }
        
        // Parse exercises first
        var exercises: [Exercise] = []
        if let exercisesArray = dict["exercises"] as? [[String: Any]] {
            exercises = try exercisesArray.compactMap { try? parseExercise(from: $0) }
        }
        
        // Create workout with exercises
        let workout = Workout(name: name, exercises: exercises)
        
        return workout
    }
    
    private func parseExercise(from dict: [String: Any]) throws -> Exercise {
        guard let name = dict["name"] as? String else {
            throw CloudError.invalidResponse
        }
        
        // Parse sets data
        let setsCount = dict["sets"] as? Int ?? 1
        let repsValue = dict["reps"] as? Int ?? 10
        let weightValue = dict["weight"] as? Double ?? 0
        let restValue = dict["restTime"] as? Int ?? 60
        
        // Create arrays for the sets
        var repsArray: [[Int]] = []
        var weightsArray: [[Double]] = []
        var restArray: [[Int]] = []
        
        // Build arrays based on number of sets
        for _ in 0..<setsCount {
            repsArray.append([repsValue])
            weightsArray.append([weightValue])
            restArray.append([restValue])
        }
        
        let exercise = Exercise(
            name: name,
            rest: restArray,
            muscleWorked: dict["muscleWorked"] as? String,
            weights: weightsArray,
            reps: repsArray,
            equipment: dict["equipment"] as? String ?? dict["weightUnit"] as? String
        )
        
        return exercise
    }
    
    private func serializeWorkout(_ workout: Workout) throws -> [String: Any] {
        var dict: [String: Any] = [
            "name": workout.name
        ]
        
        if let exercises = workout.exercises {
            dict["exercises"] = exercises.map { serializeExercise($0) }
        }
        
        // Add visibility (default to private)
        dict["visibility"] = "private"
        
        // Calculate estimated duration based on exercises
        if let exercises = workout.exercises {
            let totalMinutes = exercises.reduce(0) { total, exercise in
                let sets = exercise.reps.count
                let restPerSet = exercise.rest.first?.first ?? 60
                let estimatedSetTime = 30 // seconds per set
                return total + (sets * (estimatedSetTime + restPerSet)) / 60
            }
            dict["estimatedDuration"] = max(totalMinutes, 10) // Minimum 10 minutes
        }
        
        // Add muscle group tags
        if !workout.tags.isEmpty {
            dict["tags"] = workout.tags.map { $0.rawValue }
        }
        
        return dict
    }
    
    private func serializeExercise(_ exercise: Exercise) -> [String: Any] {
        var dict: [String: Any] = [
            "name": exercise.name
        ]
        
        // Get the number of sets
        let setsCount = exercise.reps.count
        dict["sets"] = setsCount
        
        // Get first rep count (assuming all sets have similar reps)
        if let firstRep = exercise.reps.first?.first {
            dict["reps"] = firstRep
        }
        
        // Get first weight (assuming all sets use similar weight)
        if let firstWeight = exercise.weights.first?.first, firstWeight > 0 {
            dict["weight"] = firstWeight
        }
        
        // Get rest time
        if let firstRest = exercise.rest.first?.first {
            dict["restTime"] = firstRest
        }
        
        // Add muscle worked
        if let muscleWorked = exercise.muscleWorked {
            dict["muscleWorked"] = muscleWorked
        }
        
        // Add equipment as weightUnit for API compatibility
        if let equipment = exercise.equipment {
            dict["weightUnit"] = equipment
        } else {
            dict["weightUnit"] = "lbs" // default
        }
        
        return dict
    }
}

// MARK: - Error Types

enum CloudError: LocalizedError {
    case notAuthenticated
    case invalidURL
    case invalidResponse
    case authenticationFailed(String)
    case serverError(String)
    case tokenExpired
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .tokenExpired:
            return "Your session has expired. Please sign in again."
        }
    }
}
