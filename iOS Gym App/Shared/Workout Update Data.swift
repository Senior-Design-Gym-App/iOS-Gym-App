import Foundation

extension Exercise {
    
//    var prData: [WeightEntry] {
//        let count = min(prDates.count, prWeights.count)
//        return (0..<count).map { i in
//            WeightEntry(index: i, value: prWeights[i], date: prDates[i])
//        }
//    }
    
    var setData: [[SetEntry]] {
        guard !reps.isEmpty else { return [] }
        
        var allSessions: [[SetEntry]] = []
        
        for sessionIndex in 0..<reps.count {
            var sessionSets: [SetEntry] = []
            let sessionReps = reps[sessionIndex]
            let sessionRest = rest[sessionIndex]
            let sessionWeights = weights[sessionIndex]
            
            for setIndex in 0..<sessionReps.count {
                sessionSets.append(SetEntry(
                    index: setIndex,
                    rest: sessionRest[setIndex],
                    reps: sessionReps[setIndex],
                    weight: sessionWeights[setIndex]
                ))
            }
            allSessions.append(sessionSets)
        }
        
        return allSessions
    }
    
    var updateData: [UpdateData] {
        let count = min(updateDates.count, min(reps.count, weights.count))
        return (0..<count).map { i in
            UpdateData(index: i, weights: weights[i], reps: reps[i], updateDate: updateDates[i])
        }
    }
    
    var recentSetData: [SetEntry] {
        setData.last ?? []
    }
    
}

struct UpdateData: Identifiable, Hashable {
    
    let id = UUID()
    let index: Int
    let weights: [Double]
    let reps: [Int]
    let updateDate: Date
    
    var averageVolumePerSet: Double {
        var avgWeight: Double = 0
        for set in 0..<sets {
            avgWeight += weights[set] * Double(reps[set])
        }
        return avgWeight / Double(sets)
    }
    
    var sets: Int {
        return weights.count
    }
    
}
