import SwiftUI

extension ActivityLabels {
    
    func BodyWeightLabel(currentValue: Double, previousValue: Double?, unit: String) -> String {
        var labels: [String] = [
            "\(currentValue) \(unit)",
            "Now: \(currentValue) \(unit)",
            "Updated to \(currentValue) \(unit)",
            "Set to \(currentValue) \(unit)",
            "Current weight: \(currentValue) \(unit)"
        ]
        
        if let previousValue {
            let diff = abs(currentValue - previousValue)
            
            labels.append("From \(previousValue) to \(currentValue) \(unit)")
            labels.append("\(previousValue) → \(currentValue) \(unit)")

            if currentValue > previousValue {
                labels += [
                    "Increased by \(diff) \(unit)",
                    "+\(diff) \(unit) increase",
                    "Up \(diff) \(unit)",
                    "Lift went up to \(currentValue) \(unit)",
                    "Improved from \(previousValue) \(unit)"
                ]
            } else {
                labels += [
                    "Decreased by \(diff) \(unit)",
                    "Down \(diff) \(unit)",
                    "-\(diff) \(unit) from last time",
                    "Adjusted down to \(currentValue) \(unit)",
                    "Lowered from \(previousValue) \(unit)"
                ]
            }
        }
        
        return labels.randomElement()!
    }

    
}
