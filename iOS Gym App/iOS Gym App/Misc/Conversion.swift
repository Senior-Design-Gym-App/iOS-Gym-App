import SwiftUI

class WorkoutConversionFunctions {
    
    func ConvertWeightsArray(weightsArrayString: [String], sets: Int, sameWeightForAllSets: Bool) -> [Double] {
        if sameWeightForAllSets {
            let firstWeight = weightsArrayString.first ?? "0.0"
            let filtered = firstWeight.filter { "0123456789.".contains($0) }
            let weightValue = Double(filtered) ?? 0.0
            return Array(repeating: weightValue, count: sets)
        } else {
            let convertedWeights = weightsArrayString.prefix(sets).map { weight in
                let filtered = weight.filter { "0123456789.".contains($0) }
                return Double(filtered) ?? 0.0
            }
            
            let result = Array(convertedWeights)
            let lastWeight = result.last ?? 0.0
            
            return result + Array(repeating: lastWeight, count: max(0, sets - result.count))
        }
    }
    
}
