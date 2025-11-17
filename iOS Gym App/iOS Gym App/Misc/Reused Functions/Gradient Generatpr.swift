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

enum AppColors: String {
    
    case frenchViolet       = "7400B8"
    case grape              = "6930C3"
    case slateBlue          = "5E60CE"
    case unitedNationsBlue  = "5390D9"
    case pictonBlue         = "4EA8DE"
    case aero               = "48BFE3"
    case skyBlue            = "56CFE1"
    case tiffanyBlue        = "64DFDF"
    case turquoise          = "72EFDD"
    case aquamarine         = "80FFDB"
    
    var color: Color {
        Color(hex: rawValue)
    }
    
}

enum WorkoutCharColors: String {
    
    case celadon1           = "99E2B4"
    case celadon2           = "88D4AB"
    case mint1              = "78C6A3"
    case mint2              = "67B99A"
    case zomp1              = "56AB91"
    case zomp2              = "469D89"
    case viridian           = "358F80"
    case pineGreen          = "248277"
    case skobeloff          = "14746F"
    case caribbeanCurrent   = "036666"
    
    var color: Color {
        Color(hex: rawValue)
    }
    
}
