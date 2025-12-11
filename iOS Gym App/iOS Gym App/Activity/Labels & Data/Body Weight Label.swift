import SwiftUI

extension ActivityLabels {
    
    static func BodyWeightLabel(current: WeightEntry, all: [WeightEntry], weightLabel: String) -> String {
        // Find previous entry (excluding current)
        let previous = all
            .filter { $0.date < current.date }
            .sorted { $0.date > $1.date }
            .first
                
        // If no previous entry exists
        guard let previous = previous else {
            let combinations: [String] = [
                "First measurement",
                "Starting weight",
                "Initial weigh-in",
                "Baseline measurement",
                "First entry",
                "Starting point",
                "Initial tracking"
            ]
            return combinations.randomElement()!
        }
        
        let difference = current.value - previous.value
        let diffString = abs(difference).oneDecimal
        let previousValue = previous.value.oneDecimal
        
        var combinations: [String] = []
        
        if difference < 0 {
            // Weight decreased
            combinations.append(contentsOf: [
                "Down \(diffString) \(weightLabel)",
                "Lost \(diffString) \(weightLabel)",
                "-\(diffString) \(weightLabel)",
                "Decreased \(diffString) \(weightLabel)",
                "From \(previousValue) \(weightLabel)",
                "Shed \(diffString) \(weightLabel)",
                "Down from \(previousValue) \(weightLabel)",
                "Trimmed \(diffString) \(weightLabel)",
                "Progress: -\(diffString) \(weightLabel)",
                "Weight loss: \(diffString) \(weightLabel)",
                "Dropped \(diffString) \(weightLabel)"
            ])
        } else if difference > 0 {
            // Weight increased
            combinations.append(contentsOf: [
                "Up \(diffString) \(weightLabel)",
                "Gained \(diffString) \(weightLabel)",
                "+\(diffString) \(weightLabel)",
                "Increased \(diffString) \(weightLabel)",
                "From \(previousValue) \(weightLabel)",
                "Up from \(previousValue) \(weightLabel)",
                "Added \(diffString) \(weightLabel)",
                "Progress: +\(diffString) \(weightLabel)",
                "Weight gain: \(diffString) \(weightLabel)",
                "Built \(diffString) \(weightLabel)"
            ])
        } else {
            // No change
            combinations.append(contentsOf: [
                "No change",
                "Maintained",
                "Stable",
                "Holding steady",
                "Unchanged",
                "Consistent",
                "Steady"
            ])
        }
        
        return combinations.randomElement()!
    }
    
}
