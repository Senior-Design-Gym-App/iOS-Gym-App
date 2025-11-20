//
//  AIHelperFunctions.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 11/19/25.
//
import Swift
import Foundation


class AIFunctions{
    
    struct MessagePayload: Codable {
        let message: String
    }
    
    var APIURL = URL(string: "https://api.repthesetapi.xyz/chat")
    var response = ""
    func GenericResponse(message : String) async throws -> String{
        print(message)
        let payload = MessagePayload(message: message)
        print(payload)
        
        guard let jsonData = try? JSONEncoder().encode(payload) else {
            return "Failed Encoding"
        }
        print(jsonData)
        var request = URLRequest(url:APIURL!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Decode the response
        guard let responseDict = try? JSONDecoder().decode([String: String].self, from: data),
              let responseString = responseDict["response"] else {
            throw NSError(domain: "Failed to decode response", code: -3)
        }
        
        print("Response: \(responseString)")
        return responseString
    }
    
    
    func ReturnWorkout() -> String{
        return "Push Ups"
    }
    
    func GenerateSummary() -> String{
        return "You have completed 10 push ups todays yippee!"
    }
}
