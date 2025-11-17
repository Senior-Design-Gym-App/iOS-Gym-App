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
    
    func findAverageSetData(before date: Date) -> [SetData] {
        guard let allSessionEntries = self.sessionEntries else { return [] }
        
        let previousEntries = allSessionEntries
            .filter { sessionEntry in
                guard let sessionStarted = sessionEntry.session?.started else { return false }
                return sessionStarted < date
            }
            .sorted { entry1, entry2 in
                let date1 = entry1.session?.started ?? Date.distantPast
                let date2 = entry2.session?.started ?? Date.distantPast
                return date1 > date2
            }
            .prefix(5)
        
        if previousEntries.isEmpty {
            return []
        }
        
        return calculateAverageSetData(from: Array(previousEntries))
    }
    
    private func calculateAverageSetData(from entries: [WorkoutSessionEntry]) -> [SetData] {
        guard !entries.isEmpty else { return [] }
        
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
                averageSetData.append(SetData(set: setIndex, rest: 0, reps: avgReps, weight: avgWeight))
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
                totalReps += (set.weight * Double(set.reps))
            }
        }
        return totalReps
    }
    
    var averageWeight: Double {
        return totalWeight / Double(totalReps == 0 ? 1 : totalReps)
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
        totalReps / ((reps.count * totalSets) == 0 ? 1 : (reps.count * totalSets))
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
        guard let sessions = sessionEntries else {
            return 0
        }
        var found = false
        var minValue: Double = .greatestFiniteMagnitude
        for session in sessions {
            for set in session.setEntry {
                if set.weight < minValue {
                    minValue = set.weight
                    found = true
                }
            }
        }
        return found ? minValue : 0
    }
    
    var avgSetsWeight: [WeightEntry] {
        var sets: [WeightEntry] = []
        
        for specificUpdate in updateData {
            var totalWeight = 0.0
            for set in specificUpdate.setData {
                totalWeight += set.weight
            }
            sets.append(WeightEntry(index: 0, value: totalWeight / Double(specificUpdate.setData.count), date: specificUpdate.changeDate))
        }
        
        return sets
    }
    
    func closestUpdate(date: Date) -> SetChangeData? {
        guard !updateData.isEmpty else { return nil }
        
        let sorted = updateData.sorted { $0.changeDate < $1.changeDate }
        
        if let before = sorted.last(where: { $0.changeDate <= date }) {
            return before
        }
        
        if let closest = sorted.min(by: { abs($0.changeDate.timeIntervalSince(date)) < abs($1.changeDate.timeIntervalSince(date)) }) {
            return closest
        }
        
        return nil
    }
    
}
