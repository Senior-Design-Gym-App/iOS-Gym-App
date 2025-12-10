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
    
    /// Get current ID token from Keychain
    private func getIdToken() -> String? {
        return KeychainHelper.standard.retrieveToken(key: "idToken")
    }
    
    // ADD THIS
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    // UPDATE THIS
    private func getAccessToken() -> String {
        return KeychainHelper.standard.retrieveToken(key: "accessToken") ?? ""
    }
    
    // ADD THIS - Get current user ID
    func getCurrentUserId() async throws -> String {
        // Get from AuthManager first
        if let userId = authManager?.currentUser, !userId.isEmpty {
            print("✅ Got userId from AuthManager: \(userId)")
            return userId
        }
        
        // Decode from token
        let token = KeychainHelper.standard.retrieveToken(key: "idToken") ?? ""
        guard !token.isEmpty else {
            print("❌ No ID token found")
            throw CloudError.unauthorized
        }
        
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw CloudError.invalidToken
        }
        
        var base64 = parts[1]
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder, withPad: "=", startingAt: 0)
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let userId = json["sub"] as? String else {
            print("❌ Could not decode userId from token")
            throw CloudError.invalidToken
        }
        
        print("✅ Got userId from token: \(userId)")
        return userId
    }
    
    private func decodeUserIdFromToken(_ token: String) throws -> String {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw CloudError.invalidToken
        }
        
        var base64 = parts[1]
        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder, withPad: "=", startingAt: 0)
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let userId = json["sub"] as? String else {
            throw CloudError.invalidToken
        }
        
        return userId
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
        print("Found workoutArrays \(workoutsArray)")

        var results: [Workout] = []

        for item in workoutsArray {
            guard let workoutId = item["workoutId"] as? String else { continue }
            let workout = try await fetchWorkout(workoutId: workoutId)
            results.append(workout)
        }
        return results
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
        print("Found workoutArrays \(workoutsArray)")
        
        return try workoutsArray.compactMap { try? parseWorkout(from: $0) }
    }
    
    /// Get a specific workout by ID
    func fetchWorkout(workoutId: String) async throws -> Workout {
        guard isAuthenticated else {
            throw CloudError.notAuthenticated
        }
        print("trying to get workout id \(workoutId)")
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
        print("fetched workout response: \(response)")
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
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudError.invalidResponse
        }
                
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
            do {
                exercises = try exercisesArray.compactMap { dict in
                    try parseExercise(from: dict)
                }
            } catch {
                print("Error parsing exercises:", error)
            }
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
        
        var repsArray: [[Int]] = []
        var weightsArray: [[Double]] = []
        var restArray: [[Int]] = []
        
        repsArray = dict["reps"] as! [[Int]]
        weightsArray = dict["weight"] as! [[Double]]
        restArray = dict["restTime"] as! [[Int]]
        
        let exercise = Exercise(
            name: name,
            rest: restArray,
            muscleWorked: dict["muscleWorked"] as? String,
            weights: weightsArray,
            reps: repsArray,
            equipment: dict["equipment"] as? String ?? dict["weightUnit"] as? String
        )
//        print("✅ Created exercise: \(exercise.name)")
//        print("   Reps: \(exercise.reps)")
//        print("   Weights: \(exercise.weights)")
//        print("   Rest: \(exercise.rest)")
        exercise.updateDates = [Date()]
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
        dict["visibility"] = "public"
        
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
        dict["reps"] = exercise.reps
        
        // Get first weight (assuming all sets use similar weight)
        dict["weight"] = exercise.weights
        
        // Get rest time
        dict["restTime"] = exercise.rest
        
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
    // MARK: - Social Features

    func createUserProfile(username: String, displayName: String?, bio: String?) async throws {
        guard let url = URL(string: "\(apiBaseURL)/users") else {
            throw CloudError.invalidURL
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }

        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        
        let body: [String: Any] = [
            "username": username,
            "displayName": displayName ?? username,
            "bio": bio ?? ""
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw CloudError.invalidResponse
        }
    }

    func getUserProfile(userId: String) async throws -> UserProfile {
        // CHECK: userId should be appended to the URL path
        guard let url = URL(string: "\(apiBaseURL)/users/\(userId)") else {
            throw CloudError.invalidURL
        }
        
        //print("📤 getUserProfile URL: \(url)")
        //print("📤 userId parameter: '\(userId)'")
        
        // Make sure userId isn't empty
        if userId.isEmpty {
            print("❌ ERROR: userId is empty!")
            throw CloudError.invalidURL
        }
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        //("📥 Response: \(response)")
//        if let responseString = String(data: data, encoding: .utf8) {
//            print("📥 Body: \(responseString)")
//        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CloudError.invalidResponse
        }
        let x = try JSONDecoder().decode(UserProfile.self, from: data)
        return x
    }
    
    /// Update current user's profile
    func updateUserProfile(username: String, displayName: String, bio: String, location: String?) async throws {
        // Try /users/me first (standard endpoint for updating own profile)
        var urlString = "\(apiBaseURL)/users/me"
        guard let url = URL(string: urlString) else {
            throw CloudError.invalidURL
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        var body: [String: Any] = [
            "username": username,
            "displayName": displayName,
            "bio": bio
        ]
        
        if let location = location {
            body["location"] = location
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("📤 Updating user profile: \(url)")
        print("📤 Body: \(body)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw CloudError.invalidResponse
        }
        
        print("📥 Response status: \(httpResponse.statusCode)")
        
        // If 403 or 404, try alternative approaches
        if httpResponse.statusCode == 403 || httpResponse.statusCode == 404 {
            print("⚠️ /users/me returned \(httpResponse.statusCode), trying alternatives...")
            
            // Try PATCH method first (some APIs prefer PATCH for updates)
            var patchRequest = URLRequest(url: url)
            patchRequest.httpMethod = "PATCH"
            patchRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            patchRequest.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            patchRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            print("📤 Trying PATCH method on /users/me...")
            
            let (patchData, patchResponse) = try await URLSession.shared.data(for: patchRequest)
            
            if let patchHttpResponse = patchResponse as? HTTPURLResponse,
               patchHttpResponse.statusCode == 200 {
                print("✅ PATCH method worked!")
                return
            }
            
            // If PATCH didn't work, try /users/{userId} with PUT
            print("⚠️ PATCH didn't work, trying /users/{userId} with PUT...")
            
            let userId = try await getCurrentUserId()
            urlString = "\(apiBaseURL)/users/\(userId)"
            guard let altUrl = URL(string: urlString) else {
                throw CloudError.invalidURL
            }
            
            var altRequest = URLRequest(url: altUrl)
            altRequest.httpMethod = "PUT"
            altRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            altRequest.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            altRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            print("📤 Trying alternative endpoint: \(altUrl)")
            
            let (altData, altResponse) = try await URLSession.shared.data(for: altRequest)
            
            guard let altHttpResponse = altResponse as? HTTPURLResponse else {
                throw CloudError.invalidResponse
            }
            
            print("📥 Alternative response status: \(altHttpResponse.statusCode)")
            
            if altHttpResponse.statusCode != 200 {
                if let errorString = String(data: altData, encoding: .utf8) {
                    print("❌ Error response: \(errorString)")
                }
                
                if altHttpResponse.statusCode == 401 {
                    throw CloudError.tokenExpired
                } else if altHttpResponse.statusCode == 403 {
                    throw CloudError.serverError("Permission denied (403). The API may not allow updating profiles, or your account may need additional permissions.")
                } else if altHttpResponse.statusCode == 404 {
                    throw CloudError.serverError("User profile not found (404). Please create your profile first.")
                } else {
                    throw CloudError.serverError("Server returned status \(altHttpResponse.statusCode)")
                }
            }
        } else if httpResponse.statusCode != 200 {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error response: \(errorString)")
            }
            
            if httpResponse.statusCode == 401 {
                throw CloudError.tokenExpired
            } else if httpResponse.statusCode == 403 {
                throw CloudError.serverError("Permission denied. You may not have permission to update your profile.")
            } else if httpResponse.statusCode == 404 {
                throw CloudError.serverError("User profile not found. Please create your profile first.")
            } else {
                throw CloudError.serverError("Server returned status \(httpResponse.statusCode)")
            }
        }
    }
    
    /// Get current user's own profile
    func getCurrentUserProfile() async throws -> UserProfile {
        let userId = try await getCurrentUserId()
        return try await getUserProfile(userId: userId)
    }
    
    private func decodeJWTClaims(_ token: String) -> [String: Any]? {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }
        
        var base64 = parts[1]
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder, withPad: "=", startingAt: 0)
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return json
    }
    func sendFriendRequest(to friendId: String) async throws {
        guard let url = URL(string: "\(apiBaseURL)/friends/request") else {
            throw CloudError.invalidURL
        }
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let body = ["friendId": friendId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CloudError.invalidResponse
        }
    }

    func createPost(text: String) async throws -> String {
        guard let url = URL(string: "\(apiBaseURL)/posts") else {
            throw CloudError.invalidURL
        }
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let body = ["text": text]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw CloudError.invalidResponse
        }
        
        let result = try JSONDecoder().decode([String: String].self, from: data)
        return result["postId"] ?? ""
    }

    // MARK: - Search Users

    func searchUsers(query: String) async throws -> [UserProfile] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(apiBaseURL)/users?query=\(encodedQuery)") else {
            throw CloudError.invalidURL
        }
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        //print("🔍 Searching users with query: \(query)")
        //print("📤 URL: \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        //print("📥 Response: \(response)")
        
        // PRINT THE ACTUAL ERROR
//        if let responseString = String(data: data, encoding: .utf8) {
//            print("📥 Response Body: \(responseString)")
//        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            print("❌ Status code: \(httpResponse.statusCode)")
            throw CloudError.invalidResponse
        }
        
        let result = try JSONDecoder().decode([String: [UserProfile]].self, from: data)
        return result["users"] ?? []
    }

    // MARK: - Feed

    func getFeed() async throws -> [Post] {
        guard let url = URL(string: "\(apiBaseURL)/posts/feed") else {
            throw CloudError.invalidURL
        }
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CloudError.invalidResponse
        }
        
        let result = try JSONDecoder().decode([String: [Post]].self, from: data)
        return result["posts"] ?? []
    }
    // Add to CloudManager.swift

    func getPendingFriendRequests() async throws -> [FriendRequest] {
        guard let url = URL(string: "\(apiBaseURL)/friends/pending") else {
            throw CloudError.invalidURL
        }
        //print("trying to get token")
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        //print("got token")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        //print("Pending FR response \(response)")

        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CloudError.invalidResponse
        }

        let result = try JSONDecoder().decode([String: [FriendRequest]].self, from: data)
        return result["requests"] ?? []
    }

    func acceptFriendRequest(from friendId: String) async throws {
        guard let url = URL(string: "\(apiBaseURL)/friends/accept") else {
            throw CloudError.invalidURL
        }
        //print("trying to get token")
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        //print("got token")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let body = ["friendId": friendId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        //print("Accepting Response: \(response)")
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CloudError.invalidResponse
        }
    }
    func getFriends() async throws -> [Friend] {
        guard let url = URL(string: "\(apiBaseURL)/friends") else {
            throw CloudError.invalidURL
        }
        
        guard let idToken = getIdToken() else {
            print("❌ No ID token found in Keychain")
            throw CloudError.notAuthenticated
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        print("📤 Getting friends list")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        //print("📥 Response: \(response)")
//        if let responseString = String(data: data, encoding: .utf8) {
//            print("📥 Body: \(responseString)")
//        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CloudError.invalidResponse
        }
        
        let result = try JSONDecoder().decode([String: [Friend]].self, from: data)
        return result["friends"] ?? []
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
    case unauthorized
    case invalidToken
    
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
        case .unauthorized:
            return "not authorized"
        case .invalidToken:
            return "Invalid Token"
        }
    }
}
