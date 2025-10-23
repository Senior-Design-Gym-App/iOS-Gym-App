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
