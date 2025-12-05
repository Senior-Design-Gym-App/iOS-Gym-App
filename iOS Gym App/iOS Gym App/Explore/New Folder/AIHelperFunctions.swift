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
        let reasoning: String
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
        
        guard let responseDict = try? JSONDecoder().decode([String: String].self, from: data),
              let responseString = responseDict["response"] else {
            throw AIError.decodingFailed
        }
        
        print("📥 Response: \(responseString)")
        return responseString
    }
    
    // MARK: - Alternate Exercise Function
    
    func getAlternateExercise(
        for workout: Workout,
        replacing exerciseName: String,
        userPreferences: String? = nil
    ) async throws -> (exercise: Exercise, explanation: String) {
        
        print("🔄 Getting alternate exercise for: \(exerciseName)")
        
        // Build the prompt with current workout context
        var workoutContext = "Current workout: \(workout.name)\n\nExercises:\n"
        
        if let exercises = workout.exercises {
            for exercise in exercises {
                let setsCount = exercise.reps.count
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
        }
        
        Important notes:
        - rest, weights, and reps are nested arrays where outer array = sets, inner array = values per set
        - For 3 sets, use [[val1, val2, val3]]
        - muscleWorked should be a specific muscle name (e.g., "Chest", "Quadriceps", "Biceps")
        """
        
        let payload = MessagePayload(
            message: prompt,
            systemPrompt: """
            You are an expert fitness trainer. You help users find alternate exercises that target similar muscle groups.
            Always respond with valid JSON following the exact schema provided.
            Make sure nested arrays are formatted correctly.
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
        
        // Parse response
        guard let responseDict = try? JSONDecoder().decode([String: String].self, from: data),
              let jsonString = responseDict["response"],
              let jsonData = jsonString.data(using: .utf8) else {
            throw AIError.decodingFailed
        }
        
        let alternateResponse = try JSONDecoder().decode(AlternateExerciseResponse.self, from: jsonData)
        
        // Convert to Exercise model
        let exercise = Exercise(
            name: alternateResponse.exercise.name,
            rest: alternateResponse.exercise.rest,
            muscleWorked: alternateResponse.exercise.muscleWorked,
            weights: alternateResponse.exercise.weights,
            reps: alternateResponse.exercise.reps,
            equipment: alternateResponse.exercise.equipment
        )
        
        print("✅ Found alternate: \(exercise.name)")
        print("💡 Explanation: \(alternateResponse.explanation)")
        
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
            Ensure nested arrays are properly formatted.
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
            let exercise = Exercise(
                name: exerciseData.name,
                rest: exerciseData.rest,
                muscleWorked: exerciseData.muscleWorked,
                weights: exerciseData.weights,
                reps: exerciseData.reps,
                equipment: exerciseData.equipment
            )
            
            print("✅ Created exercise: \(exercise.name)")
            print("   Reps: \(exercise.reps)")
            print("   Weights: \(exercise.weights)")
            print("   Rest: \(exercise.rest)")
            
            return exercise
        }
        
        print("got exercises: \(exercises)")
        
        let summary = workoutResponse.summary
        let tips = workoutResponse.tips
        
        print("✅ Generated workout: \(workoutName)")
        print("📝 Summary: \(summary)")
        
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
}
