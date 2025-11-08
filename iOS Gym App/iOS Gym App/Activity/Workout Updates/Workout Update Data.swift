import Foundation

extension Exercise {
    
//    var prData: [WeightEntry] {
//        let count = min(prDates.count, prWeights.count)
//        return (0..<count).map { i in
//            WeightEntry(index: i, value: prWeights[i], date: prDates[i])
//        }
//    }

    
    var updateData: [SetChangeData] {
        let outerCount = min(updateDates.count, min(reps.count, weights.count))
        var allUpdates: [SetChangeData] = []
        
        for i in 0..<outerCount {
            var sessionSets: [SetData] = []
            let innerCount = min(weights[i].count, reps[i].count)
            for j in 0..<innerCount {
                sessionSets.append(SetData(set: j, rest: rest[i][j], reps: reps[i][j], weight: weights[i][j]))
            }
            allUpdates.append(SetChangeData(changeDate: updateDates[i], setData: sessionSets))
        }
        return allUpdates
    }
    
    var recentSetData: SetChangeData {
        updateData.last ?? SetChangeData(changeDate: Date.distantPast, setData: [])
    }
    
    func findAverageSetDataForExercises(in session: WorkoutSession) -> [SetData] {
        guard let currentExercises = session.exercises else {
            return []
        }
        
        var result: [Exercise: [SetData]] = [:]
        
        // Get the reference date (use session start date)
        let referenceDate = session.started
        
        for entry in currentExercises {
            guard let exercise = entry.exercise else { continue }
            guard let allSessionEntries = exercise.sessionEntries else { continue }
            
            // Filter entries from sessions before the current session
            let previousEntries = allSessionEntries
                .filter { sessionEntry in
                    guard let sessionStarted = sessionEntry.session?.started else { return false }
                    return sessionStarted < referenceDate
                }
                .sorted { entry1, entry2 in
                    let date1 = entry1.session?.started ?? Date.distantPast
                    let date2 = entry2.session?.started ?? Date.distantPast
                    return date1 > date2 // Most recent first
                }
                .prefix(5) // Take only the 5 most recent
            
            if !previousEntries.isEmpty {
                let averageSetData = calculateAverageSetData(from: Array(previousEntries))
                result[exercise] = averageSetData
            }
        }
        
        return result.values.flatMap(\.self)
    }

    func calculateAverageSetData(from entries: [WorkoutSessionEntry]) -> [SetData] {
        guard !entries.isEmpty else { return [] }
        
        // Find the maximum number of sets across all entries
        let maxSets = entries.map { $0.setEntry.count }.max() ?? 0
        
        var averageSetData: [SetData] = []
        
        for setIndex in 0..<maxSets {
            var totalReps = 0
            var totalWeight = 0.0
            var count = 0
            
            for entry in entries {
                if setIndex < entry.setEntry.count {
                    let set = entry.setEntry[setIndex]
                    totalReps += set.reps
                    totalWeight += set.weight
                    count += 1
                }
            }
            
            if count > 0 {
                let avgReps = Int(round(Double(totalReps) / Double(count)))
                let avgWeight = totalWeight / Double(count)
                averageSetData.append(SetData(set: 0, rest: setIndex, reps: avgReps, weight: avgWeight))
            }
        }
        
        return averageSetData
    }
    
    var totalSets: Int {
        guard let sessions = sessionEntries else {
            return 0
        }
        var count: Int = 0
        for session in sessions {
            count += session.setEntry.count
        }
        return count
    }
    
    var totalReps: Int {
        guard let sessions = sessionEntries else {
            return 0
        }
        var totalReps: Int = 0
        for session in sessions {
            for set in session.setEntry {
                totalReps += set.reps
            }
        }
        return totalReps
    }
    
    var totalWeight: Double {
        guard let sessions = sessionEntries else {
            return 0
        }
        var totalReps: Double = 0
        for session in sessions {
            for set in session.setEntry {
                totalReps += set.weight
            }
        }
        return totalReps
    }
    
    var averageWeight: Double {
        return totalWeight / Double(totalSets)
    }
    
    var maxReps: Int {
        guard let sessions = sessionEntries else {
            return 0
        }
        var max: Int = 0
        for session in sessions {
            for set in session.setEntry {
                if set.reps > max {
                    max = set.reps
                }
            }
        }
        return max
    }
    
    var averageReps: Int {
        totalReps / reps.count
    }
    
    var maxWeight: Double {
        guard let sessions = sessionEntries else {
            return 0
        }
        var max: Double = 0
        for session in sessions {
            for set in session.setEntry {
                if set.weight > max {
                    max = set.weight
                }
            }
        }
        return max
    }
    
    var minWeight: Double {
        guard let session = sessionEntries else {
            return 0
        }
        var min: Double = 1000
        for session in session {
            for set in session.setEntry {
                if set.weight < min {
                    min = set.weight
                }
            }
        }
        return min
    }
    
}
