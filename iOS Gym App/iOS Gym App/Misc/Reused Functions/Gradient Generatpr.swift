import Foundation
import SwiftUI

class ColorManager {
    
    static let shared = ColorManager()
    private var colors: [String: Color] = [:]
    
    func GetColor(key: String) -> Color {
        if let gradient = colors[key] {
            return gradient
        } else {
            let gradient = GenerateRandomColor()
            colors[key] = gradient
            return gradient
        }
    }
    
    private func GenerateRandomColor() -> Color {
        Color(
            hue: Double.random(in: 0...1),
            saturation: Double.random(in: 0.6...0.9),
            brightness: Double.random(in: 0.7...1.0)
        )
    }
    
}

enum MuscleGroupColor: String {
    
    case rose               = "F72585"
    case fandago            = "B5179E"
    case grape              = "7209B7"
    case chryslerBlue       = "560BAD"
    case darkBlue           = "480CA8"
    case zaffe              = "3A0CA3"
    case palatinateBlue     = "3F37C9"
    case neonBlue           = "4361EE"
    case chefchaouenBlue    = "4895EF"
    case vividSkyBlue       = "4CC9F0"
    
    var color: Color {
        Color(hex: rawValue)
    }
    
}
