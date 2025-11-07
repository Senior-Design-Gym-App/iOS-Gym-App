import SwiftData
import SwiftUI
import Foundation
import Observation

@Model
final class Exercise {
    
    var name: String = ""
    var muscleWorked: String?
    
    var updateDates: [Date] = []
    var rest: [[Int]] = []
    var reps: [[Int]] = []
    var weights: [[Double]] = []
    
    var equipment: String?
    var created = Date()
    var modified = Date()
    
    @Relationship(deleteRule: .nullify)
    var workouts: [Workout]?
    @Relationship(deleteRule: .cascade)
    var sessionEntries: [WorkoutSessionEntry]? = []
    
    init(name: String, rest: [[Int]], muscleWorked: String?, weights: [[Double]], reps: [[Int]], equipment: String?) {
        self.name = name
        self.rest = rest
        self.muscleWorked = muscleWorked
        self.weights = weights
        self.reps = reps
        self.equipment = equipment
    }
    
    var muscleGroup: MuscleGroup? {
        if let muscleWorked {
            Muscle(rawValue: muscleWorked)?.specific
        } else {
            nil
        }
    }
    
    var muscle: Muscle? {
        if let muscleWorked {
            Muscle(rawValue: muscleWorked)
        } else {
            nil
        }
    }
    
    var workoutEquipment: WorkoutEquipment? {
        if let equipment {
            WorkoutEquipment(rawValue: equipment)
        } else {
            nil
        }
    }
    
    var color: Color {
        if let muscleGroup {
            muscleGroup.colorPalette
        } else {
            Constants.mainAppTheme
        }
    }
        
}

extension Color {
    
    init(hex: String) {
        var rgb: UInt64 = 0
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        Scanner(string: cleanHex).scanHexInt64(&rgb)
        
        let length = cleanHex.count
        let r, g, b, a: Double
        
        switch length {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
            a = 1.0
        default:
            r = 0.5; g = 0.5; b = 0.5; a = 1.0
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
}

extension Array where Element == Color {
    
    func averageColor() -> Color {
        guard !self.isEmpty else {
            return Color.gray // Default color if array is empty
        }
        
        var totalRed: Double = 0
        var totalGreen: Double = 0
        var totalBlue: Double = 0
        var totalOpacity: Double = 0
        
        for color in self {
            let uiColor = UIColor(color)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            totalRed += red
            totalGreen += green
            totalBlue += blue
            totalOpacity += alpha
        }
        
        let count = Double(self.count)
        
        return Color(
            red: totalRed / count,
            green: totalGreen / count,
            blue: totalBlue / count,
            opacity: totalOpacity / count
        )
    }
}
