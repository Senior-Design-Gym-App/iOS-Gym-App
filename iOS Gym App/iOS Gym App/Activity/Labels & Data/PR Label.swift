import SwiftUI

extension ActivityLabels {
    
    func UpdatePRLabel(current: WeightEntry, all: [WeightEntry], workoutName: String) -> String {
        // Sort all entries by value, highest first
        let sorted = all.sorted { $0.value > $1.value }
        guard let highest = sorted.first else { return "" }
        
        // Check if this entry is the highest (new PR)
        if current.value >= highest.value && current.index == highest.index {
            // Find previous PR (excluding this one)
            let previousPR = all.filter { $0.index != current.index }.max(by: { $0.value < $1.value })

            var combinations: [String] = []
            let valueString = current.value.oneDecimal

            if let prev = previousPR {
                let prevString = String(format: "%.1f", prev.value)
                let diff = current.value - prev.value
                let diffString = String(format: "+%.1f", diff)
                combinations += [
                    "New PR! \(valueString) \(WLabel()) on \(workoutName) — Up by \(diffString) from your last best!",
                    "PR smashed! \(valueString) \(WLabel()) (was \(prevString) \(WLabel())",
                    "Crushed your old PR: \(prevString) → \(valueString) \(WLabel()) in \(workoutName)",
                    "Personal Record! \(valueString) \(WLabel()) (up \(diffString) from last PR)",
                    "You set a new record in \(workoutName): \(valueString) \(WLabel())!"
                ]
            } else {
                combinations += [
                    "First ever PR in \(workoutName)! \(valueString) \(WLabel()) logged!",
                    "Personal Record set: \(valueString) \(WLabel()) in \(workoutName)",
                    "Congrats! Your first PR: \(valueString) \(WLabel()) for \(workoutName)",
                    "Brand new PR: \(valueString) \(WLabel())! Keep going!"
                ]
            }

            return combinations.randomElement()!
        }
        
        return "Unknown Error"
    }
    
}
