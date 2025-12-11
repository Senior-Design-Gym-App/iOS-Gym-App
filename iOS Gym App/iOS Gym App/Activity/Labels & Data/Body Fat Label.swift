import SwiftUI

extension ActivityLabels {
    
    static func BodyFatLabel(current: WeightEntry, all: [WeightEntry]) -> String {
        // Find previous entry (excluding current)
        let previous = all
            .filter { $0.date < current.date }
            .sorted { $0.date > $1.date }
            .first
                
        // If no previous entry exists
        guard let previous = previous else {
            let combinations: [String] = [
                "First measurement",
                "Starting body fat",
                "Initial reading",
                "Baseline measurement",
                "First entry",
                "Starting point",
                "Initial body composition"
            ]
            return combinations.randomElement()!
        }
        
        let difference = current.value - previous.value
        let diffString = abs(difference).oneDecimal
        let previousValue = previous.value.oneDecimal
        
        var combinations: [String] = []
        
        if difference < 0 {
            // Body fat decreased (positive progress)
            combinations.append(contentsOf: [
                "Down \(diffString)%",
                "Lost \(diffString)%",
                "-\(diffString)%",
                "Decreased \(diffString)%",
                "From \(previousValue)%",
                "Down from \(previousValue)%",
                "Trimmed \(diffString)%",
                "Progress: -\(diffString)%",
                "Leaned out \(diffString)%",
                "Dropped \(diffString)%",
                "Reduced \(diffString)%"
            ])
        } else if difference > 0 {
            // Body fat increased
            combinations.append(contentsOf: [
                "Up \(diffString)%",
                "Gained \(diffString)%",
                "+\(diffString)%",
                "Increased \(diffString)%",
                "From \(previousValue)%",
                "Up from \(previousValue)%",
                "Added \(diffString)%",
                "Rose \(diffString)%",
                "Changed: +\(diffString)%"
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
