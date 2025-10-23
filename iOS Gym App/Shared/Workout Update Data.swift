import Foundation

extension Exercise {
    
//    var prData: [WeightEntry] {
//        let count = min(prDates.count, prWeights.count)
//        return (0..<count).map { i in
//            WeightEntry(index: i, value: prWeights[i], date: prDates[i])
//        }
//    }
    
    var updateData: [UpdateData] {
        let count = min(updateDates.count, min(reps.count, weights.count))
        return (0..<count).map { i in
            UpdateData(index: i, weights: weights[i], reps: reps[i], updateDate: updateDates[i])
        }
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
