import SwiftUI

extension ActivityLabels {
    
    func BodyFatLabel(currentValue: Double, previousValue: Double?) -> String {
        let unit: String = "%"
        var labels: [String] = [
            "\(String(format: "%.1f", currentValue))\(unit)",
            "Current body fat: \(String(format: "%.1f", currentValue))\(unit)",
            "Body fat at \(String(format: "%.1f", currentValue))\(unit)",
            "Updated body fat: \(String(format: "%.1f", currentValue))\(unit)"
        ]
        
        if let previousValue {
            let diff = abs(currentValue - previousValue)
            let diffStr = String(format: "%.1f", diff)
            let prevStr = String(format: "%.1f", previousValue)
            let currStr = String(format: "%.1f", currentValue)
            
            labels.append("Changed from \(prevStr)\(unit) to \(currStr)\(unit)")
            labels.append("\(prevStr)\(unit) → \(currStr)\(unit)")
            
            if currentValue < previousValue {
                labels += [
                    "Body fat decreased by \(diffStr)\(unit) — great progress!",
                    "Reduced body fat by \(diffStr)\(unit)",
                    "Lean down! Down \(diffStr)\(unit) body fat",
                    "Lowered from \(prevStr)\(unit) to \(currStr)\(unit)",
                    "You lost \(diffStr)\(unit) body fat"
                ]
            } else {
                labels += [
                    "Body fat increased by \(diffStr)\(unit)",
                    "Up \(diffStr)\(unit) in body fat",
                    "Increased from \(prevStr)\(unit) to \(currStr)\(unit)",
                    "Gained \(diffStr)\(unit) body fat",
                    "Body fat went up — \(diffStr)\(unit) higher"
                ]
            }
        }
        
        return labels.randomElement()!
    }

    
}
