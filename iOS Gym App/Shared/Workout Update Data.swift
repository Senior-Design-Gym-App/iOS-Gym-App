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
                sessionSets.append(SetData(rest: rest[i][j], reps: reps[i][j], weight: weights[i][j]))
            }
            allUpdates.append(SetChangeData(changeDate: updateDates[i], setData: sessionSets))
        }
        return allUpdates
    }
    
    var recentSetData: SetChangeData {
        updateData.last ?? SetChangeData(changeDate: Date.distantPast, setData: [])
    }
    
}
