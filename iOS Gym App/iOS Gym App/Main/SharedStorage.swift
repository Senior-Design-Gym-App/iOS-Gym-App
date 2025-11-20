//
//  SharedStorage.swift
//  Shared between iOS and Watch
//
//  Optional: Only needed if you want App Groups
//

import Foundation

final class SharedStorage {
    static let shared = SharedStorage()
    
    // MARK: - App Group Configuration
    
    // Change this to your App Group ID
    private let appGroupID = "group.com.SeniorDesign.iOSGymApp"
    
    private lazy var sharedDefaults: UserDefaults? = {
        return UserDefaults(suiteName: appGroupID)
    }()
    
    // MARK: - Keys
    
    private enum Keys {
        static let workouts = "cachedWorkouts"
        static let activeSplit = "cachedActiveSplit"
        static let lastSync = "lastSyncDate"
    }
    
    // MARK: - Save/Load Methods
    
    func saveWorkouts(_ workouts: [WorkoutTransfer]) {
        do {
            let data = try JSONEncoder().encode(workouts)
            sharedDefaults?.set(data, forKey: Keys.workouts)
            print("✅ Saved workouts to App Group")
        } catch {
            print("❌ Failed to save workouts: \(error)")
        }
    }
    
    func loadWorkouts() -> [WorkoutTransfer] {
        guard let data = sharedDefaults?.data(forKey: Keys.workouts) else {
            print("❌ No cached workouts in App Group")
            return []
        }
        
        do {
            let workouts = try JSONDecoder().decode([WorkoutTransfer].self, from: data)
            print("✅ Loaded \(workouts.count) workouts from App Group")
            return workouts
        } catch {
            print("❌ Failed to decode workouts: \(error)")
            return []
        }
    }
    
    func saveActiveSplit(_ split: SplitTransfer) {
        do {
            let data = try JSONEncoder().encode(split)
            sharedDefaults?.set(data, forKey: Keys.activeSplit)
        } catch {
            print("❌ Failed to save split: \(error)")
        }
    }
    
    func loadActiveSplit() -> SplitTransfer? {
        guard let data = sharedDefaults?.data(forKey: Keys.activeSplit) else {
            return nil
        }
        
        return try? JSONDecoder().decode(SplitTransfer.self, from: data)
    }
    
    func saveLastSyncDate(_ date: Date) {
        sharedDefaults?.set(date, forKey: Keys.lastSync)
    }
    
    func loadLastSyncDate() -> Date? {
        return sharedDefaults?.object(forKey: Keys.lastSync) as? Date
    }
}
