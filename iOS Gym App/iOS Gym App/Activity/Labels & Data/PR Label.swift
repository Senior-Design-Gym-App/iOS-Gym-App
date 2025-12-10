import SwiftUI

extension ActivityLabels {
    
    static func OneRepMaxLabel(current: WeightEntry, all: [WeightEntry], label: String) -> String {
        // Sort all entries by value, highest first
        let sorted = all.sorted { $0.value > $1.value }
        guard let highest = sorted.first else { return "" }
        
        // Check if this entry is the highest (new PR)
        if current.value >= highest.value && current.index == highest.index {
            // Find previous PR (excluding this one)
            let previousPR = all.filter { $0.index != current.index }.max(by: { $0.value < $1.value })
            
            let valueString = current.value.oneDecimal
            let isPR = previousPR == nil || current.value > previousPR!.value
            
            var combinations: [String] = []
            
            // Basic achievement formats
            combinations.append(contentsOf: [
                "One rep max of \(valueString) \(label)",
                "Hit one rep max: \(valueString) \(label)",
                "One rep max achieved: \(valueString) \(label)",
                "Reached 1RM of \(valueString) \(label)",
                "1RM: \(valueString) \(label)",
                "New one rep max: \(valueString) \(label)"
            ])
            
            // Abbreviated variations
            combinations.append(contentsOf: [
                "1RM hit: \(valueString) \(label)",
                "Max lift: \(valueString) \(label)",
                "Peak strength: \(valueString) \(label)",
                "Top lift: \(valueString) \(label)"
            ])
            
            // Action-oriented formats
            combinations.append(contentsOf: [
                "Maxed out at \(valueString) \(label)",
                "Hit \(valueString) \(label) for 1RM",
                "Lifted \(valueString) \(label) (1RM)",
                "Achieved \(valueString) \(label) single",
                "Completed \(valueString) \(label) max"
            ])
            
            // Celebratory formats
            combinations.append(contentsOf: [
                "Crushed \(valueString) \(label) 1RM",
                "Dominated \(valueString) \(label)",
                "Conquered \(valueString) \(label) max",
                "Nailed \(valueString) \(label) single"
            ])
            
            // If it's a PR, add PR variations
            if isPR {
                var prCombinations: [String] = [
                    "One rep max of \(valueString) \(label) (PR)",
                    "Hit one rep max: \(valueString) \(label) (PR)",
                    "New PR: \(valueString) \(label) 1RM",
                    "Personal record: \(valueString) \(label)",
                    "PR achieved: \(valueString) \(label)",
                    "1RM PR: \(valueString) \(label)",
                    "New personal best: \(valueString) \(label)",
                    "Hit PR at \(valueString) \(label)",
                    "Broke PR with \(valueString) \(label)",
                    "Set new record: \(valueString) \(label)",
                    "Personal best of \(valueString) \(label)",
                    "Smashed PR: \(valueString) \(label)",
                    "New max PR: \(valueString) \(label)",
                    "PR unlocked: \(valueString) \(label)",
                    "Strongest yet: \(valueString) \(label) (PR)"
                ]
                
                // If there's a previous PR, add comparison formats
                if let previousPR = previousPR {
                    let improvement = current.value - previousPR.value
                    let improvementString = improvement.oneDecimal
                    
                    prCombinations.append(contentsOf: [
                        "New PR: \(valueString) \(label) (+\(improvementString))",
                        "Beat PR by \(improvementString) \(label)",
                        "PR: \(valueString) \(label) (up \(improvementString))",
                        "Improved PR to \(valueString) \(label)",
                        "+\(improvementString) \(label) PR (\(valueString) total)",
                        "Previous: \(previousPR.value.oneDecimal), New: \(valueString) \(label) PR"
                    ])
                }
                
                combinations.append(contentsOf: prCombinations)
            }
            
            return combinations.randomElement()!
        }
        
        return "Unknown Error"
    }
    
}
