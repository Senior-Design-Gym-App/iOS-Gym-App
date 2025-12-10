import SwiftUI

extension ActivityLabels {
    
    static func BodyWeightLabel(current: WeightEntry, all: [WeightEntry], weightLabel: String) -> String {
        // Find previous entry (excluding current)
        let previous = all
            .filter { $0.index != current.index }
            .sorted { $0.index > $1.index }
            .first
        
        let currentValue = current.value.oneDecimal
        
        // If no previous entry exists
        guard let previous = previous else {
            let combinations: [String] = [
                "Body weight: \(currentValue) \(weightLabel)",
                "Starting weight: \(currentValue) \(weightLabel)",
                "Initial weigh-in: \(currentValue) \(weightLabel)",
                "First measurement: \(currentValue) \(weightLabel)",
                "Baseline: \(currentValue) \(weightLabel)",
                "Tracked at \(currentValue) \(weightLabel)",
                "Weight recorded: \(currentValue) \(weightLabel)",
                "Weighed in at \(currentValue) \(weightLabel)"
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
                "Weight down to \(currentValue) \(weightLabel)",
                "Dropped to \(currentValue) \(weightLabel)",
                "Lost \(diffString) \(weightLabel)",
                "Down \(diffString) \(weightLabel): now \(currentValue)",
                "Weighed in at \(currentValue) \(weightLabel)",
                "Cut to \(currentValue) \(weightLabel)",
                "Decreased \(diffString) \(weightLabel)",
                "Weight: \(previousValue) → \(currentValue) \(weightLabel)",
                "-\(diffString) \(weightLabel)",
                "Shed \(diffString) \(weightLabel)",
                "Now at \(currentValue) \(weightLabel) (down \(diffString))",
                "Lighter at \(currentValue) \(weightLabel)",
                "Progress: \(currentValue) \(weightLabel) (-\(diffString))",
                "Trimmed \(diffString) \(weightLabel)",
                "Leaned down to \(currentValue) \(weightLabel)",
                "Weight loss: \(diffString) \(weightLabel)",
                "Slimmed to \(currentValue) \(weightLabel)"
            ])
        } else if difference > 0 {
            // Weight increased
            combinations.append(contentsOf: [
                "Weight up to \(currentValue) \(weightLabel)",
                "Increased to \(currentValue) \(weightLabel)",
                "Gained \(diffString) \(weightLabel)",
                "Up \(diffString) \(weightLabel): now \(currentValue)",
                "Weighed in at \(currentValue) \(weightLabel)",
                "Weight: \(previousValue) → \(currentValue) \(weightLabel)",
                "+\(diffString) \(weightLabel)",
                "Now at \(currentValue) \(weightLabel) (up \(diffString))",
                "Bulked to \(currentValue) \(weightLabel)",
                "Added \(diffString) \(weightLabel)",
                "Heavier at \(currentValue) \(weightLabel)",
                "Progress: \(currentValue) \(weightLabel) (+\(diffString))",
                "Weight gain: \(diffString) \(weightLabel)",
                "Grew to \(currentValue) \(weightLabel)",
                "Built up to \(currentValue) \(weightLabel)"
            ])
        } else {
            // No change
            combinations.append(contentsOf: [
                "Weight maintained at \(currentValue) \(weightLabel)",
                "Stable at \(currentValue) \(weightLabel)",
                "Holding at \(currentValue) \(weightLabel)",
                "Unchanged: \(currentValue) \(weightLabel)",
                "Consistent at \(currentValue) \(weightLabel)",
                "Still at \(currentValue) \(weightLabel)",
                "Maintained \(currentValue) \(weightLabel)",
                "No change: \(currentValue) \(weightLabel)",
                "Steady at \(currentValue) \(weightLabel)"
            ])
        }
        
        return combinations.randomElement()!
    }
    
}
