import SwiftUI

final class ActivityLabels {
    
    private let DH = DateHandler()
    @AppStorage("useLBs") private var useLBs = true
    
//    func UpdateDataLabel(specificUpdate: UpdateData, allUpdates: [UpdateData], workoutName: String) -> String {
//        
//        let previousEntry = allUpdates.first(where: { $0.index == specificUpdate.index - 1 })
//        let type = DetermineUpdateType(current: specificUpdate, previous: previousEntry)
//        
//        switch type {
//        case .weights:
//            return GenerateWeightsLabel(current: specificUpdate, previous: previousEntry!, workoutName: workoutName)
//        case .reps:
//            return GenerateRepLabel(current: specificUpdate, previous: previousEntry!, workoutName: workoutName)
//        case .sets:
//            return GenerateSetsLabel(current: specificUpdate, previous: previousEntry!, workoutName: workoutName)
//        case .setsAndReps:
//            return GenerateSetsAndReps(current: specificUpdate, previous: previousEntry!, workoutName: workoutName)
//        case .setsAndWeight:
//            return GenerateSetsAndWeights(current: specificUpdate, previous: previousEntry!, workoutName: workoutName)
//        case .repsAndWeight:
//            return GenerateRepsAndWeight(current: specificUpdate, previous: previousEntry!, workoutName: workoutName)
//        case .all:
//            return GenerateAll(current: specificUpdate, previous: previousEntry!, workoutName: workoutName)
//        case .none:
//            return GenerateNone(current: specificUpdate, workoutName: workoutName)
//        }
//    }
//    
//    private func DetermineUpdateType(current: UpdateData, previous: UpdateData?) -> UpdateType {
//        
//        if let previous {
//            
//            if previous.sets == current.sets && previous.reps == current.reps && previous.weights == current.weights {
//                return .all
//            } else if previous.sets == current.sets && previous.reps == current.reps {
//                return .setsAndReps
//            } else if previous.sets == current.sets && previous.weights == current.weights {
//                return .setsAndWeight
//            } else if previous.reps == current.reps && previous.weights == current.weights {
//                return .repsAndWeight
//            } else if previous.sets == current.sets {
//                return .sets
//            } else if previous.reps == current.reps {
//                return .reps
//            } else if previous.weights == current.weights {
//                return .weights
//            } else {
//                return .none
//            }
//        } else {
//            return .none
//        }
//    }
//    
//    private func GenerateWeightsLabel(current: UpdateData, previous: UpdateData, workoutName: String) -> String {
//        var combinations: [String] = []
//        let currentAvgWeight = previous.weights.reduce(0, +) / Double(previous.weights.count)
//        let previousAvgWeight = previous.weights.reduce(0, +) / Double(previous.weights.count)
//        
//        if currentAvgWeight > previousAvgWeight {
//            let increase = (currentAvgWeight - previousAvgWeight).oneDecimal
//            combinations += [
//                "Weight increase on \(workoutName): +\(increase) average",
//                "You lifted heavier on \(workoutName) — up \(increase) on average",
//                "Strength gain! \(workoutName) weight increased by \(increase)",
//                "Progressive overload on \(workoutName): +\(increase) average weight",
//                "You pushed more weight on \(workoutName) today",
//                "Heavier weights conquered on \(workoutName)",
//                "Weight progression: \(workoutName) got tougher today"
//            ]
//        } else {
//            let decrease = (previousAvgWeight - currentAvgWeight).oneDecimal
//            combinations += [
//                "Weight adjustment on \(workoutName): -\(decrease) average",
//                "Dialed back the weight on \(workoutName) by \(decrease)",
//                "Smart deload on \(workoutName) — reduced weight by \(decrease)",
//                "Taking it easier on \(workoutName) today with lighter weight",
//                "Recovery focused: reduced \(workoutName) weight",
//                "Strategic weight reduction on \(workoutName)",
//                "Lowered the intensity on \(workoutName) today"
//            ]
//        }
//        
//        combinations += [
//            "New weights loaded for \(workoutName)",
//            "Weight adjustment complete on \(workoutName)",
//            "Different loading scheme for \(workoutName)",
//            "Updated your \(workoutName) weights"
//        ]
//        
//        return combinations.randomElement()!
//    }
//    
//    private func GenerateRepLabel(current: UpdateData, previous: UpdateData, workoutName: String) -> String {
//        var combinations: [String] = []
//        
//        let currentTotalReps = previous.reps.reduce(0, +)
//        let previousTotalReps = previous.reps.reduce(0, +)
//        let currentAvgReps = Double(currentTotalReps) / Double(previous.sets)
//        let previousAvgReps = Double(previousTotalReps) / Double(previous.sets)
//        
//        if currentTotalReps > previousTotalReps {
//            let moreReps = currentTotalReps - previousTotalReps
//            combinations += [
//                "Rep increase on \(workoutName): +\(moreReps) total reps",
//                "You squeezed out \(moreReps) more reps on \(workoutName)",
//                "Volume boost! \(workoutName) gained \(moreReps) reps",
//                "Endurance improvement: +\(moreReps) reps on \(workoutName)",
//                "More reps conquered on \(workoutName) today",
//                "Rep progression on \(workoutName) — \(moreReps) extra reps",
//                "You went deeper on \(workoutName) with \(moreReps) more reps"
//            ]
//        } else {
//            let fewerReps = previousTotalReps - currentTotalReps
//            combinations += [
//                "Rep adjustment on \(workoutName): -\(fewerReps) total reps",
//                "Reduced reps on \(workoutName) by \(fewerReps)",
//                "Quality over quantity: fewer reps on \(workoutName)",
//                "Focused approach: -\(fewerReps) reps on \(workoutName)",
//                "Strategic rep reduction on \(workoutName)",
//                "Dialed back reps on \(workoutName) today",
//                "Less volume, same intensity on \(workoutName)"
//            ]
//        }
//        
//        if currentAvgReps > previousAvgReps {
//            combinations.append("Higher average reps per set on \(workoutName)")
//        } else if currentAvgReps < previousAvgReps {
//            combinations.append("Lower average reps per set on \(workoutName)")
//        }
//        
//        combinations += [
//            "New rep scheme for \(workoutName)",
//            "Rep pattern updated on \(workoutName)",
//            "Different rep structure for \(workoutName)",
//            "Modified your \(workoutName) rep count"
//        ]
//        
//        return combinations.randomElement()!
//    }
//    
//    private func GenerateSetsLabel(current: UpdateData, previous: UpdateData, workoutName: String) -> String {
//        var combinations: [String] = []
//        
//        if current.sets > previous.sets {
//            let moreSets = current.sets - previous.sets
//            combinations += [
//                "Added \(moreSets) more set\(moreSets == 1 ? "" : "s") to \(workoutName)",
//                "Volume increase: +\(moreSets) set\(moreSets == 1 ? "" : "s") on \(workoutName)",
//                "Extended your \(workoutName) with \(moreSets) extra set\(moreSets == 1 ? "" : "s")",
//                "More work done: \(moreSets) additional set\(moreSets == 1 ? "" : "s") on \(workoutName)",
//                "You went the extra mile with \(moreSets) more set\(moreSets == 1 ? "" : "s") on \(workoutName)",
//                "Doubled down on \(workoutName) — added \(moreSets) set\(moreSets == 1 ? "" : "s")",
//                "Extended session: \(moreSets) bonus set\(moreSets == 1 ? "" : "s") on \(workoutName)"
//            ]
//        } else {
//            let fewerSets = previous.sets - current.sets
//            combinations += [
//                "Reduced \(workoutName) by \(fewerSets) set\(fewerSets == 1 ? "" : "s")",
//                "Streamlined approach: -\(fewerSets) set\(fewerSets == 1 ? "" : "s") on \(workoutName)",
//                "Quality focus: fewer sets on \(workoutName)",
//                "Shortened your \(workoutName) by \(fewerSets) set\(fewerSets == 1 ? "" : "s")",
//                "Strategic reduction: \(fewerSets) less set\(fewerSets == 1 ? "" : "s") on \(workoutName)",
//                "Efficient session: cut \(fewerSets) set\(fewerSets == 1 ? "" : "s") from \(workoutName)",
//                "Focused approach: trimmed \(workoutName) sets"
//            ]
//        }
//        
//        combinations += [
//            "New set structure for \(workoutName)",
//            "Set count modified on \(workoutName)",
//            "Different volume approach for \(workoutName)",
//            "Updated your \(workoutName) set scheme"
//        ]
//        
//        return combinations.randomElement()!
//    }
//    
//    private func GenerateSetsAndReps(current: UpdateData, previous: UpdateData, workoutName: String) -> String {
//        var combinations: [String] = []
//        
//        let currentTotalReps = current.reps.reduce(0, +)
//        let previousTotalReps = previous.reps.reduce(0, +)
//        let currentVolume = current.averageVolumePerSet
//        let previousVolume = previous.averageVolumePerSet
//        
//        if current.sets > previous.sets && currentTotalReps > previousTotalReps {
//            combinations += [
//                "Major volume increase on \(workoutName) — more sets AND reps",
//                "You cranked up the volume on \(workoutName) big time",
//                "Volume explosion: both sets and reps increased on \(workoutName)",
//                "All-out effort: more sets and reps on \(workoutName)",
//                "Volume beast mode on \(workoutName) today"
//            ]
//        } else if current.sets < previous.sets && currentTotalReps < previousTotalReps {
//            combinations += [
//                "Scaled back volume on \(workoutName) — fewer sets and reps",
//                "Recovery focus: reduced sets and reps on \(workoutName)",
//                "Strategic deload on \(workoutName) volume",
//                "Less is more approach on \(workoutName) today",
//                "Quality over quantity: trimmed \(workoutName) volume"
//            ]
//        } else {
//            combinations += [
//                "Mixed volume approach on \(workoutName)",
//                "Balanced adjustment to \(workoutName) structure",
//                "Creative restructure of \(workoutName)",
//                "New volume distribution on \(workoutName)"
//            ]
//        }
//        
//        if currentVolume > previousVolume {
//            combinations.append("Higher training volume achieved on \(workoutName)")
//        } else if currentVolume < previousVolume {
//            combinations.append("Reduced training volume on \(workoutName)")
//        }
//        
//        combinations += [
//            "Complete volume overhaul on \(workoutName)",
//            "New sets and reps structure for \(workoutName)",
//            "Modified your \(workoutName) training volume"
//        ]
//        
//        return combinations.randomElement()!
//    }
//    
//    private func GenerateSetsAndWeights(current: UpdateData, previous: UpdateData, workoutName: String) -> String {
//        var combinations: [String] = []
//        
//        let currentAvgWeight = current.weights.reduce(0, +) / Double(current.weights.count)
//        let previousAvgWeight = previous.weights.reduce(0, +) / Double(previous.weights.count)
//        
//        if current.sets > previous.sets && currentAvgWeight > previousAvgWeight {
//            combinations += [
//                "Double progression on \(workoutName): more sets AND heavier weight",
//                "Intensity and volume increase on \(workoutName)",
//                "You leveled up \(workoutName) — more sets with heavier weight",
//                "Progressive overload mastery on \(workoutName)",
//                "Both volume and intensity jumped on \(workoutName)"
//            ]
//        } else if current.sets < previous.sets && currentAvgWeight < previousAvgWeight {
//            combinations += [
//                "Strategic deload on \(workoutName): fewer sets with lighter weight",
//                "Recovery mode: reduced sets and weight on \(workoutName)",
//                "Taking it easy on \(workoutName) — less volume and intensity",
//                "Smart recovery approach on \(workoutName)"
//            ]
//        } else if current.sets > previous.sets && currentAvgWeight < previousAvgWeight {
//            combinations += [
//                "Volume up, intensity down on \(workoutName)",
//                "More sets with lighter weight on \(workoutName)",
//                "High-volume approach on \(workoutName) today"
//            ]
//        } else if current.sets < previous.sets && currentAvgWeight > previousAvgWeight {
//            combinations += [
//                "Intensity up, volume down on \(workoutName)",
//                "Fewer sets with heavier weight on \(workoutName)",
//                "High-intensity approach on \(workoutName) today"
//            ]
//        }
//        
//        combinations += [
//            "New intensity and volume combo on \(workoutName)",
//            "Modified sets and loading on \(workoutName)"
//        ]
//        
//        return combinations.randomElement()!
//    }
//    
//    private func GenerateRepsAndWeight(current: UpdateData, previous: UpdateData, workoutName: String) -> String {
//        var combinations: [String] = []
//        
//        let currentAvgWeight = current.weights.reduce(0, +) / Double(current.weights.count)
//        let previousAvgWeight = previous.weights.reduce(0, +) / Double(previous.weights.count)
//        let currentTotalReps = current.reps.reduce(0, +)
//        let previousTotalReps = previous.reps.reduce(0, +)
//        
//        if currentTotalReps > previousTotalReps && currentAvgWeight > previousAvgWeight {
//            combinations += [
//                "Double win on \(workoutName): more reps AND heavier weight",
//                "Strength and endurance gains on \(workoutName)",
//                "You dominated \(workoutName) — more reps with more weight",
//                "Peak performance on \(workoutName) today",
//                "Everything improved on \(workoutName)"
//            ]
//        } else if currentTotalReps < previousTotalReps && currentAvgWeight < previousAvgWeight {
//            combinations += [
//                "Strategic scaling on \(workoutName): fewer reps with lighter weight",
//                "Recovery focus on \(workoutName) — reduced reps and weight",
//                "Taking a step back on \(workoutName) for recovery"
//            ]
//        } else if currentTotalReps > previousTotalReps && currentAvgWeight < previousAvgWeight {
//            combinations += [
//                "Endurance focus on \(workoutName): more reps with lighter weight",
//                "High-rep approach on \(workoutName) today",
//                "Volume-focused session on \(workoutName)"
//            ]
//        } else if currentTotalReps < previousTotalReps && currentAvgWeight > previousAvgWeight {
//            combinations += [
//                "Strength focus on \(workoutName): fewer reps with heavier weight",
//                "Power approach on \(workoutName) today",
//                "Quality reps with serious weight on \(workoutName)"
//            ]
//        }
//        
//        combinations += [
//            "New rep and weight combination on \(workoutName)",
//            "Modified intensity and reps on \(workoutName)"
//        ]
//        
//        return combinations.randomElement()!
//    }
//    
//    private func GenerateAll(current: UpdateData, previous: UpdateData, workoutName: String) -> String {
//        var combinations: [String] = []
//        
//        let currentVolume = current.averageVolumePerSet
//        let previousVolume = previous.averageVolumePerSet
//        
//        if currentVolume > previousVolume {
//            combinations += [
//                "Total transformation on \(workoutName) — everything improved",
//                "Complete upgrade to your \(workoutName) game",
//                "Full send on \(workoutName): sets, reps, AND weight all changed",
//                "You revolutionized your \(workoutName) today",
//                "Next-level \(workoutName) session — everything evolved"
//            ]
//        } else if currentVolume < previousVolume {
//            combinations += [
//                "Complete restructure of \(workoutName) for recovery",
//                "Full reset on \(workoutName) — everything adjusted down",
//                "Total deload on \(workoutName) today"
//            ]
//        } else {
//            combinations += [
//                "Creative restructure of \(workoutName)",
//                "Fresh approach to \(workoutName) — everything changed",
//                "New formula for \(workoutName) success",
//                "Complete reimagining of \(workoutName)"
//            ]
//        }
//        
//        combinations += [
//            "Total \(workoutName) makeover complete",
//            "Every parameter changed on \(workoutName)",
//            "Strategic overhaul of \(workoutName) approach"
//        ]
//        
//        return combinations.randomElement()!
//    }
//    
//    private func GenerateNone(current: UpdateData, workoutName: String) -> String {
//        var combinations: [String] = []
//        
//        combinations += [
//            "Updated \(workoutName)",
//            "Changed \(workoutName)",
//            "Modified \(workoutName)",
//            "Updated \(workoutName)",
//            "Recorded \(workoutName)",
//            "Tracked \(workoutName)",
//            "Completed another \(workoutName)",
//            "\(workoutName) session logged"
//        ]
//        
//            combinations += [
//                "Started tracking \(workoutName)",
//                "New exercise: \(workoutName)",
//                "Added \(workoutName)"
//            ]
//                
//        return combinations.randomElement()!
//    }
    
    func WLabel() -> String {
        switch useLBs {
        case true:
            return "lbs"
        case false:
            return "kg"
        }
    }
    
}
