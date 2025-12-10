//
//  AIHelperFunctions.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 11/19/25.
//

import Swift
import Foundation

class AIFunctions {
    
    // MARK: - Request/Response Models
    
    struct MessagePayload: Codable {
        let message: String
        let systemPrompt: String?
        let responseFormat: String? // "json" or "text"
    }
    struct AIResponse: Codable {
        let response: String
        let metadata: ResponseMetadata
    }

    struct ResponseMetadata: Codable {
        let model: String
        let tokensUsed: Int
        let format: String
        
        enum CodingKeys: String, CodingKey {
            case model
            case tokensUsed = "tokens_used"
            case format
        }
    }
    
    // Simplified models that match your SwiftData structure
    struct ExerciseResponse: Codable {
        let name: String
        let muscleWorked: String?
        let rest: [[Int]]
        let weights: [[Double]]
        let reps: [[Int]]
        let equipment: String?
    }
    
    struct WorkoutResponse: Codable {
        let name: String
        let exercises: [ExerciseResponse]
    }
    
    struct AlternateExerciseResponse: Codable {
        let exercise: ExerciseResponse
        let explanation: String
    }
    
    struct WorkoutGenerationResponse: Codable {
        let workout: WorkoutResponse
        let summary: String
        let tips: [String]
    }
    
    // MARK: - Configuration
    
    private static func getConfigValue(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("Missing \(key) in Info.plist")
        }
        return value
    }
    
    private let APIURL: URL
            
    init() {
        self.APIURL = URL(string: AIFunctions.getConfigValue(for: "OpenAICallback"))!
    }
    
    // MARK: - Generic Response (Original Function)
    
    func genericResponse(message: String) async throws -> String {
        print("📤 Sending message: \(message)")
        
        let payload = MessagePayload(
            message: message,
            systemPrompt: "You are a helpful fitness assistant.",
            responseFormat: "text"
        )
        
        guard let jsonData = try? JSONEncoder().encode(payload) else {
            throw AIError.encodingFailed
        }
        
        var request = URLRequest(url: APIURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.invalidResponse
        }
        
        // Decode using the proper structure
        let aiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
        
        print("📥 Response: \(aiResponse.response)")
        print("📊 Metadata - Model: \(aiResponse.metadata.model), Tokens: \(aiResponse.metadata.tokensUsed)")
        
        return aiResponse.response
    }
    
    // MARK: - Alternate Exercise Function
    
    func getAlternateExercise(
        for workout: Workout,
        replacing exerciseName: String,
        userPreferences: String? = nil
    ) async throws -> (exercise: Exercise, explanation: String) {
        
        print("🔄 Getting alternate exercise for: \(exerciseName)")
        let startTime = Date()
        // Build the prompt with current workout context
        var workoutContext = "Current workout: \(workout.name)\n\nExercises:\n"
        
        if let exercises = workout.exercises {
            for exercise in exercises {
                let setsCount = exercise.reps.first?.count ?? 0
                workoutContext += "- \(exercise.name): \(setsCount) sets"
                if let muscle = exercise.muscleWorked {
                    workoutContext += " (targets \(muscle))"
                }
                workoutContext += "\n"
            }
        }
        
        // Build full prompt
        var prompt = """
        \(workoutContext)
        
        Exercise to replace: "\(exerciseName)"
        """
        
        if let preferences = userPreferences {
            prompt += "\nUser preferences: \(preferences)"
        }
        
        prompt += """
        
        
        Provide an alternate exercise that:
        1. Is NOT already in the workout
        2. Targets similar muscle groups as "\(exerciseName)"
        3. Has appropriate sets, reps, weights, and rest times
        
        Respond with ONLY valid JSON in this exact format:
        {
          "exercise": {
            "name": "Dumbbell Bench Press",
            "muscleWorked": "Chest",
            "equipment": "Dumbbells",
            "reps": [[10, 10, 10]],
            "weights": [[50, 50, 50]],
            "rest": [[90, 90, 90]]
          },
          "explanation": "This exercise targets the same muscle groups and provides a similar movement pattern."
        }
        
        Important notes:
        - rest, weights, and reps are nested arrays where outer array = workout sessions, inner array = sets
        - For 3 sets, use [[val1, val2, val3]]
        - muscleWorked should be a specific muscle name (e.g., "Chest", "Quadriceps", "Biceps")
        - equipment should be specific (e.g., "Barbell", "Dumbbells", "Bodyweight")
        - Make sure nested arrays for rest, weights, and reps are all the same length
        """
        
        let payload = MessagePayload(
            message: prompt,
            systemPrompt: """
            You are an expert fitness trainer. You help users find alternate exercises that target similar muscle groups.
            Always respond with valid JSON following the exact schema provided.
            Make sure nested arrays are formatted correctly and all have the same length.
            """,
            responseFormat: "json"
        )
        
        guard let jsonData = try? JSONEncoder().encode(payload) else {
            throw AIError.encodingFailed
        }
        
        var request = URLRequest(url: APIURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.invalidResponse
        }
        
        print("📦 Raw response data:")
        if let rawString = String(data: data, encoding: .utf8) {
            print(rawString)
        }
        
        // Parse as our expected response structure
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ Failed to parse as JSON object")
            throw AIError.decodingFailed
        }
        
        print("✅ Parsed JSON object, keys:", jsonObject.keys)
        
        guard let jsonString = jsonObject["response"] as? String else {
            print("❌ No 'response' key or wrong type")
            print("Available keys:", jsonObject.keys)
            throw AIError.decodingFailed
        }
        
        print("✅ Found response string")
        
        // Clean escaped characters
        let cleanedJSON = jsonString
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\t", with: "\t")
        
        print("📄 Cleaned JSON:")
        print(cleanedJSON)
        
        guard let cleanedData = cleanedJSON.data(using: .utf8) else {
            throw AIError.decodingFailed
        }
        
        let alternateResponse = try JSONDecoder().decode(AlternateExerciseResponse.self, from: cleanedData)
        
        // Normalize arrays to ensure they match
        let normalized = normalizeExerciseArrays(alternateResponse.exercise)
        
        // Convert to Exercise model
        let exercise = Exercise(
            name: alternateResponse.exercise.name,
            rest: normalized.rest,
            muscleWorked: alternateResponse.exercise.muscleWorked,
            weights: normalized.weights,
            reps: normalized.reps,
            equipment: alternateResponse.exercise.equipment
        )
        
        // Add updateDates so recentSetData works
        exercise.updateDates = [Date()]
        
        print("✅ Found alternate: \(exercise.name)")
        print("   Reps: \(exercise.reps)")
        print("   Weights: \(exercise.weights)")
        print("   Rest: \(exercise.rest)")
        print("💡 Explanation: \(alternateResponse.explanation)")
        
        print("Generating Alternate Exercise took \(Date().timeIntervalSince(startTime)) seconds")
        
        return (exercise, alternateResponse.explanation)
    }
    
    // MARK: - Generate Complete Workout
    
    func generateWorkout(
        workoutType: String,
        targetMuscles: [String]? = nil,
        duration: Int? = nil,
        equipment: [String]? = nil,
        fitnessLevel: String? = nil,
        additionalNotes: String? = nil
    ) async throws -> (name: String, exercises: [Exercise], summary: String, tips: [String]) {
        
        print("🏋️ Generating workout: \(workoutType)")
        let startTime = Date()

        var prompt = "Create a \(workoutType) workout"
        
        if let muscles = targetMuscles, !muscles.isEmpty {
            prompt += " targeting \(muscles.joined(separator: ", "))"
        }
        
        if let dur = duration {
            prompt += " that takes approximately \(dur) minutes"
        }
        
        if let equip = equipment, !equip.isEmpty {
            prompt += " using \(equip.joined(separator: ", "))"
        }
        
        if let level = fitnessLevel {
            prompt += " for a \(level) fitness level"
        }
        
        if let notes = additionalNotes {
            prompt += ".\n\nAdditional notes: \(notes)"
        }
        
        prompt += """
        
        
        Respond with ONLY valid JSON in this exact format:
        {
            "workout":
            {
              "exercises" : [
                {
                  "equipment" : "Not specified",
                  "muscleWorked" : "",
                  "name" : "Test1",
                  "reps" : [
                    [

                    ]
                  ],
                  "rest" : [
                    [

                    ]
                  ],
                  "weights" : [
                    [

                    ]
                  ]
                },
                {
                  "equipment" : "Not specified",
                  "muscleWorked" : "",
                  "name" : "Test2",
                  "reps" : [
                    [

                    ],
                    [
                      15,
                      15,
                      15,
                      15
                    ]
                  ],
                  "rest" : [
                    [

                    ],
                    [
                      65,
                      65,
                      65,
                      65
                    ]
                  ],
                  "weights" : [
                    [

                    ],
                    [
                      0,
                      0,
                      0,
                      0
                    ]
                  ]
                },
                {
                  "equipment" : "Not specified",
                  "muscleWorked" : "",
                  "name" : "New Exercise",
                  "reps" : [
                    [

                    ],
                    [
                      8,
                      8
                    ]
                  ],
                  "rest" : [
                    [

                    ],
                    [
                      60,
                      60
                    ]
                  ],
                  "weights" : [
                    [

                    ],
                    [
                      67,
                      67
                    ]
                  ]
                }
              ],
              "name" : "Workout2"
            },
            "summary": "Brief 2-3 sentence summary of the workout",
            "tips": ["Tip 1", "Tip 2", "Tip 3"]
        }
        
        Important notes:
        - Include 4-6 exercises with appropriate sets, reps, weights, and rest times
        - rest, weights, and reps are nested arrays: outer array = sets, inner array = values per set
        - For 3 sets of an exercise, format like: [[val1, val2, val3]]
        - muscleWorked should be specific muscle names (e.g., "Chest", "Quadriceps", "Triceps")
        - equipment should be specific equipment (e.g., "Barbell", "Dumbbells", "Bodyweight")
        """
        
        let payload = MessagePayload(
            message: prompt,
            systemPrompt: """
            You are an expert fitness trainer and workout designer.
            Always respond with valid JSON following the exact schema provided.
            Create balanced, effective workouts appropriate for the user's fitness level.
            Ensure nested arrays are properly formatted. Make sure nested arrays for the same exercise are always the same length, i.e. rest, weights, and reps should all be equal length.
            Make sure the schema is exactly as written with 3 outer keys of workout, summary, and tips
            """,
            responseFormat: "json"
        )
        
        guard let jsonData = try? JSONEncoder().encode(payload) else {
            throw AIError.encodingFailed
        }
        
        var request = URLRequest(url: APIURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print(jsonData)
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.invalidResponse
        }

        print("📦 Raw response data:")
        if let rawString = String(data: data, encoding: .utf8) {
            print(rawString)
        }

        // Try to parse as our expected response structure
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ Failed to parse as JSON object")
            throw AIError.decodingFailed
        }

        print("✅ Parsed JSON object, keys:", jsonObject.keys)

        guard let jsonString = jsonObject["response"] as? String else {
            print("❌ No 'response' key or wrong type")
            print("Available keys:", jsonObject.keys)
            print("Response type:", type(of: jsonObject["response"]))
            throw AIError.decodingFailed
        }

        print("✅ Found response string")

        // Clean escaped characters
        let cleanedJSON = jsonString
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\t", with: "\t")

        print("📄 Cleaned JSON:")
        print(cleanedJSON)

        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw AIError.decodingFailed
        }

        let workoutResponse = try JSONDecoder().decode(WorkoutGenerationResponse.self, from: jsonData)
        
        // Handle both response formats
        let workoutName = workoutResponse.workout.name
        let exercisesData = workoutResponse.workout.exercises
        
        // Convert to Exercise objects
        let exercises = exercisesData.map { exerciseData in
            
            let normalized = normalizeExerciseArrays(exerciseData)

            let exercise = Exercise(
                name: exerciseData.name,
                rest: normalized.rest,
                muscleWorked: exerciseData.muscleWorked,
                weights: normalized.weights,
                reps: normalized.reps,
                equipment: exerciseData.equipment
            )
            
            print("✅ Created exercise: \(exercise.name)")
            print("   Reps: \(exercise.reps)")
            print("   Weights: \(exercise.weights)")
            print("   Rest: \(exercise.rest)")
            exercise.updateDates = [Date()]
            return exercise
        }
        
        print("got exercises: \(exercises)")
        
        let summary = workoutResponse.summary
        let tips = workoutResponse.tips
        
        print("✅ Generated workout: \(workoutName)")
        print("📝 Summary: \(summary)")
        
        print("Generating Workout took \(Date().timeIntervalSince(startTime)) seconds")

        
        return (workoutName, exercises, summary, tips)
    }
    	
    // MARK: - Errors
    
    enum AIError: LocalizedError {
        case encodingFailed
        case decodingFailed
        case invalidResponse
        case networkError
        
        var errorDescription: String? {
            switch self {
            case .encodingFailed:
                return "Failed to encode request"
            case .decodingFailed:
                return "Failed to decode response"
            case .invalidResponse:
                return "Invalid response from server"
            case .networkError:
                return "Network error occurred"
            }
        }
    }
    private func normalizeExerciseArrays(_ exerciseData: ExerciseResponse) -> (reps: [[Int]], weights: [[Double]], rest: [[Int]]) {
        let reps = exerciseData.reps
        let weights = exerciseData.weights
        let rest = exerciseData.rest
        
        // Get the structure from reps (it's the most reliable)
        let outerCount = reps.count  // Number of workout sessions
        
        var normalizedWeights: [[Double]] = []
        var normalizedRest: [[Int]] = []
        
        for i in 0..<outerCount {
            let targetCount = reps[i].count  // Number of sets in this session
            
            // Normalize weights
            if i < weights.count {
                let weightSession = weights[i]
                if weightSession.count == targetCount {
                    // Already correct length
                    normalizedWeights.append(weightSession)
                } else if weightSession.isEmpty {
                    // No weights provided, use 0
                    normalizedWeights.append(Array(repeating: 0.0, count: targetCount))
                } else {
                    // Extend or truncate to match reps
                    let lastWeight = weightSession.last ?? 0.0
                    var newWeights = weightSession
                    while newWeights.count < targetCount {
                        newWeights.append(lastWeight)
                    }
                    normalizedWeights.append(Array(newWeights.prefix(targetCount)))
                }
            } else {
                // Session doesn't exist in weights, use 0
                normalizedWeights.append(Array(repeating: 0.0, count: targetCount))
            }
            
            // Normalize rest
            if i < rest.count {
                let restSession = rest[i]
                if restSession.count == targetCount {
                    // Already correct length
                    normalizedRest.append(restSession)
                } else if restSession.isEmpty {
                    // No rest provided, use default 60 seconds
                    normalizedRest.append(Array(repeating: 60, count: targetCount))
                } else {
                    // Extend or truncate to match reps
                    let lastRest = restSession.last ?? 60
                    var newRest = restSession
                    while newRest.count < targetCount {
                        newRest.append(lastRest)
                    }
                    normalizedRest.append(Array(newRest.prefix(targetCount)))
                }
            } else {
                // Session doesn't exist in rest, use default 60
                normalizedRest.append(Array(repeating: 60, count: targetCount))
            }
        }
        
        return (reps, normalizedWeights, normalizedRest)
    }
    func generateSessionSummary(
        for session: WorkoutSession
    ) async throws -> String {
        
        print("📝 Generating summary for session: \(session.name)")
        let startTime = Date()
        // Build session context
        var sessionContext = """
        Session: \(session.name)
        Date: \(formatDate(session.started))
        Duration: \(calculateDuration(start: session.started, end: session.completed))
        
        Exercises completed:
        """
        
        if let exercises = session.exercises {
            for entry in exercises {
                guard let exercise = entry.exercise else { continue }
                
                let sets = entry.reps.count
                let totalReps = entry.reps.reduce(0, +)
                let totalWeight = entry.weight.reduce(0, +)
                let avgWeight = totalWeight / Double(max(sets, 1))
                
                sessionContext += """
                \n- \(exercise.name): \(sets) sets, \(totalReps) total reps, avg \(String(format: "%.1f", avgWeight)) lbs
                """
                
                if let muscle = exercise.muscleWorked {
                    sessionContext += " (targets \(muscle))"
                }
            }
        }
        
        // Add performance comparison if available
        if let workout = session.workout, let previousSession = findPreviousSession(for: workout, before: session.started) {
            sessionContext += "\n\nPrevious session: \(formatDate(previousSession.started))"
        }
        
        let prompt = """
        \(sessionContext)
        
        Create a concise 3-4 sentence summary of this workout session. Focus on:
        1. Overall effort and performance
        2. Key exercises or muscle groups worked
        3. Any notable achievements or patterns
        
        Be encouraging and specific. Use a friendly, motivational tone.
        """
        
        let payload = MessagePayload(
            message: prompt,
            systemPrompt: """
            You are an expert fitness coach providing personalized workout summaries.
            Keep summaries concise (3-4 sentences), encouraging, and specific to the workout data.
            Highlight achievements and progress naturally.
            """,
            responseFormat: "text"
        )
        
        guard let jsonData = try? JSONEncoder().encode(payload) else {
            throw AIError.encodingFailed
        }
        
        var request = URLRequest(url: APIURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.invalidResponse
        }
        
        print("📦 Raw response data:")
        if let rawString = String(data: data, encoding: .utf8) {
            print(rawString)
        }
        
        // Parse as our expected response structure
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ Failed to parse as JSON object")
            throw AIError.decodingFailed
        }
        
        print("✅ Parsed JSON object, keys:", jsonObject.keys)
        
        guard let responseString = jsonObject["response"] as? String else {
            print("❌ No 'response' key or wrong type")
            print("Available keys:", jsonObject.keys)
            throw AIError.decodingFailed
        }
        
        print("✅ Found response string")
        
        // Clean escaped characters (even though it's text, not JSON)
        let cleanedSummary = responseString
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\t", with: "\t")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("📄 Cleaned summary:")
        print(cleanedSummary)
        print("Generating AI Summary took \(Date().timeIntervalSince(startTime)) seconds")

        print("✅ Generated summary")
        return cleanedSummary
    }

    // MARK: - Helper Functions

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func calculateDuration(start: Date, end: Date?) -> String {
        guard let end = end else { return "Incomplete" }
        
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func findPreviousSession(for workout: Workout, before date: Date) -> WorkoutSession? {
        guard let sessions = workout.sessions else { return nil }
        
        return sessions
            .filter { $0.completed != nil && $0.started < date }
            .sorted { $0.started > $1.started }
            .first
    }
}
