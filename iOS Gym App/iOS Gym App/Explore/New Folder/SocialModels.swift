//
//  SocialModels.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/8/25.
//

import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String
    let username: String
    let displayName: String
    let bio: String
    let isPublic: Bool
    let followers: Int
    let following: Int
    let location: String?
    let profileImageUrl: String?  // Add this
    let coverImageUrl: String?    // Add this
    let workoutCount: Int?        // For the stats
    
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case username, displayName, bio, isPublic, followers, following
        case location, profileImageUrl, coverImageUrl, workoutCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        displayName = try container.decode(String.self, forKey: .displayName)
        bio = try container.decode(String.self, forKey: .bio)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        location = try? container.decode(String.self, forKey: .location)
        profileImageUrl = try? container.decode(String.self, forKey: .profileImageUrl)
        coverImageUrl = try? container.decode(String.self, forKey: .coverImageUrl)
        workoutCount = try? container.decode(Int.self, forKey: .workoutCount)
        
        // Handle followers - can be String or Int
        if let followersInt = try? container.decode(Int.self, forKey: .followers) {
            followers = followersInt
        } else if let followersString = try? container.decode(String.self, forKey: .followers),
                  let followersInt = Int(followersString) {
            followers = followersInt
        } else {
            followers = 0
        }
        
        // Handle following - can be String or Int
        if let followingInt = try? container.decode(Int.self, forKey: .following) {
            following = followingInt
        } else if let followingString = try? container.decode(String.self, forKey: .following),
                  let followingInt = Int(followingString) {
            following = followingInt
        } else {
            following = 0
        }
    }
}
struct Post: Codable, Identifiable {
    let id: String
    let userId: String
    let text: String
    let createdAt: String
    let username: String?
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "postId"
        case userId, text, createdAt, username, displayName
    }
    
    var timeAgo: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else { return "Recently" }
        
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

struct Friendship: Codable {
    let userId: String
    let friendId: String
    let status: String
    let requestedAt: String
}
struct Friend: Codable, Identifiable {
    let userId: String
    let username: String?
    let displayName: String?
    let bio: String?
    let acceptedAt: String?
    
    var id: String { userId }
}
struct FriendRequest: Codable, Identifiable {
    let userId: String
    let username: String?
    let displayName: String?
    let requestedAt: String?
    
    var id: String { userId }
}
