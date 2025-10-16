import SwiftUI
import SwiftData

@Model
final class WorkoutSplit {
    
    var name: String = ""
    @Relationship(deleteRule: .nullify)
    var days: [WorkoutDay]? = []
    var created: Date = Date.now
    var modified: Date = Date.now
    var imageData: Data?
    var colorHex: String?
    var pinned: Bool = false
    
    var image: UIImage? {
        get {
            guard let imageData else { return nil }
            return UIImage(data: imageData)
        }
    }
    
    var color: Color {
        if let colorHex {
            return Color(hex: colorHex)
        } else {
            return Constants.mainAppTheme
        }
    }
    
    init(name: String, days: [WorkoutDay]? = nil, created: Date, modified: Date, imageData: Data? = nil, pinned: Bool) {
        self.name = name
        self.days = days
        self.created = created
        self.modified = modified
        self.imageData = imageData
        self.pinned = pinned
    }
    
}

extension Color {
    /// Initialize a Color from a hex string (e.g., "#FF5733" or "FF5733")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black if invalid
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert a Color to a hex string
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
