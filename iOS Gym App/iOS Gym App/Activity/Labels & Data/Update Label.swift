import SwiftUI

final class ActivityLabels {
        
    func UpdateDataLabel(specificUpdate: SetChangeData, allUpdates: [SetChangeData]) -> String {
        
        let previous = allUpdates
            .filter { $0.changeDate < specificUpdate.changeDate }
            .max(by: { $0.changeDate < $1.changeDate })
        
        let current = specificUpdate
        
        if let previous {
            
            if previous.reps == current.reps && previous.sets == current.sets && previous.rest == current.rest && previous.weight == current.weight {
                
                let options: [String] = [
                    "Complete change",
                    "Overhauled",
                    "Total reset",
                    "Fresh start",
                    "Full modification",
                    "Completely revised"
                ]
                
                return options.randomElement()!
                
            } else {
                
                var changedItems: [String] = []
                
                if previous.reps != current.reps {
                    changedItems.append("reps")
                }
                
                if previous.sets != current.sets {
                    changedItems.append("sets")
                }
                
                if previous.rest != current.rest {
                    changedItems.append("rest")
                }
                
                if previous.weight != current.weight {
                    changedItems.append("weight")
                }
                
                return generateChangeDescription(changedItems: changedItems)
                
            }
            
        } else {
            
            let options: [String] = [
                "Created exercise",
                "Initial entry",
                "First time tracked",
                "New exercise added",
                "Started tracking",
                "Exercise initialized"
            ]
            
            return options.randomElement()!
            
        }
                
    }
    
    private func generateChangeDescription(changedItems: [String]) -> String {
        
        switch changedItems.count {
        case 1:
            return singleChangeDescriptions(item: changedItems[0])
            
        case 2:
            return doubleChangeDescriptions(items: changedItems)
            
        case 3:
            return tripleChangeDescriptions(items: changedItems)
            
        case 4:
            return [
                "Complete change",
                "Full update",
                "Everything adjusted",
                "Total overhaul"
            ].randomElement()!
            
        default:
            return "Updated"
        }
    }
    
    private func singleChangeDescriptions(item: String) -> String {
        switch item {
        case "reps":
            return ["Changed reps", "Adjusted reps", "Modified rep count", "New rep scheme", "Reps updated"].randomElement()!
        case "sets":
            return ["Changed sets", "Adjusted sets", "Modified set count", "New volume", "Sets updated"].randomElement()!
        case "rest":
            return ["Changed rest", "Adjusted rest time", "Modified recovery", "New rest period", "Rest updated"].randomElement()!
        case "weight":
            return ["Changed weight", "Adjusted load", "Modified weight", "New weight", "Weight updated"].randomElement()!
        default:
            return "Updated"
        }
    }
    
    private func doubleChangeDescriptions(items: [String]) -> String {
        let sorted = items.sorted()
        let combo = sorted.joined(separator: "+")
        
        let descriptions: [String: [String]] = [
            "reps+sets": [
                "Changed volume",
                "Adjusted reps & sets",
                "Modified workout volume",
                "New rep/set scheme",
                "Volume update"
            ],
            "reps+rest": [
                "Changed reps & rest",
                "Adjusted intensity",
                "Modified reps and recovery",
                "New tempo"
            ],
            "reps+weight": [
                "Changed reps & weight",
                "Adjusted intensity",
                "Modified load and reps",
                "New strength focus"
            ],
            "rest+sets": [
                "Changed sets & rest",
                "Adjusted volume & recovery",
                "Modified sets and rest time",
                "New pacing"
            ],
            "sets+weight": [
                "Changed sets & weight",
                "Adjusted volume & load",
                "Modified intensity",
                "New strength protocol"
            ],
            "rest+weight": [
                "Changed weight & rest",
                "Adjusted load & recovery",
                "Modified intensity timing",
                "New weight with rest change"
            ]
        ]
        
        return descriptions[combo]?.randomElement() ?? "Updated \(items[0]) & \(items[1])"
    }
    
    private func tripleChangeDescriptions(items: [String]) -> String {
        let sorted = items.sorted()
        let combo = sorted.joined(separator: "+")
        
        let descriptions: [String: [String]] = [
            "reps+rest+sets": [
                "Major volume change",
                "Overhauled workout structure",
                "Changed sets, reps & rest",
                "New training protocol"
            ],
            "reps+rest+weight": [
                "Major intensity shift",
                "Changed weight, reps & rest",
                "Overhauled intensity",
                "New strength approach"
            ],
            "reps+sets+weight": [
                "Complete intensity change",
                "Changed volume & load",
                "Overhauled reps, sets & weight",
                "New training intensity"
            ],
            "rest+sets+weight": [
                "Major workout change",
                "Changed sets, weight & rest",
                "Overhauled training approach",
                "New workout structure"
            ]
        ]
        
        return descriptions[combo]?.randomElement() ?? "Changed \(items[0]), \(items[1]) & \(items[2])"
    }
    
}
