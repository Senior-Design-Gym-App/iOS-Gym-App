import SwiftUI

extension ActivityLabels {
    
    static func BodyFatLabel(current: WeightEntry, all: [WeightEntry]) -> String {
        // Find previous entry (excluding current)
        let previous = all
            .filter { $0.index != current.index }
            .sorted { $0.index > $1.index }
            .first
        
        let currentValue = current.value.oneDecimal
        
        // If no previous entry exists
        guard let previous = previous else {
            let combinations: [String] = [
                "Body fat: \(currentValue)%",
                "Starting body fat: \(currentValue)%",
                "Initial reading: \(currentValue)%",
                "Body composition: \(currentValue)%",
                "First measurement: \(currentValue)%",
                "Baseline: \(currentValue)% body fat",
                "Tracked at \(currentValue)%",
                "Body fat recorded: \(currentValue)%"
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
                "Body fat down to \(currentValue)%",
                "Reduced to \(currentValue)% body fat",
                "Dropped to \(currentValue)%",
                "Lost \(diffString)% body fat",
                "Down \(diffString)%: now \(currentValue)%",
                "Leaned out to \(currentValue)%",
                "Cut to \(currentValue)% body fat",
                "Decreased \(diffString)%",
                "Shredded down to \(currentValue)%",
                "Body fat: \(previousValue)% → \(currentValue)%",
                "-\(diffString)% body fat",
                "Trimmed \(diffString)% off",
                "Now at \(currentValue)% (down \(diffString)%)",
                "Improved to \(currentValue)%",
                "Reached \(currentValue)% body fat",
                "Progress: \(currentValue)% (-\(diffString)%)",
                "Leaner at \(currentValue)%"
            ])
        } else if difference > 0 {
            // Body fat increased
            combinations.append(contentsOf: [
                "Body fat up to \(currentValue)%",
                "Increased to \(currentValue)%",
                "Rose to \(currentValue)% body fat",
                "Gained \(diffString)% body fat",
                "Up \(diffString)%: now \(currentValue)%",
                "Body fat: \(previousValue)% → \(currentValue)%",
                "+\(diffString)% body fat",
                "Now at \(currentValue)% (up \(diffString)%)",
                "Changed to \(currentValue)%",
                "Increased \(diffString)%",
                "Bulked to \(currentValue)%",
                "Body composition: \(currentValue)% (+\(diffString)%)",
                "Added \(diffString)%"
            ])
        } else {
            // No change
            combinations.append(contentsOf: [
                "Body fat maintained at \(currentValue)%",
                "Stable at \(currentValue)%",
                "Holding at \(currentValue)% body fat",
                "Unchanged: \(currentValue)%",
                "Consistent at \(currentValue)%",
                "Still at \(currentValue)%",
                "Maintained \(currentValue)% body fat",
                "No change: \(currentValue)%"
            ])
        }
        
        return combinations.randomElement()!
    }

}
