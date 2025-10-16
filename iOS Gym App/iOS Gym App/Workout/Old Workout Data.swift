import Foundation
import SwiftData
import PhotosUI

@Model
final class Exercise {
    
    var speed: String?
    var link: String = ""
    var name: String = ""
    var other: String = ""
    var muscleWorked: String = ""
    var rest: Int = 0
    var order: Int = 0
    var sets: Int?
    var minreps: Int?
    var maxreps: Int?
    var duration: Double?
    var weights: [Double] = []
    var completed: Bool = false
    
    init(link: String, name: String, other: String, sets: Int? = nil, rest: Int, order: Int, minreps: Int? = nil, maxreps: Int? = nil, muscleWorked: String, weights: [Double], duration: Double? = nil, speed: String? = nil) {
        self.link = link
        self.name = name
        self.other = other
        self.sets = sets
        self.rest = rest
        self.order = order
        self.minreps = minreps
        self.maxreps = maxreps
        self.muscleWorked = muscleWorked
        self.weights = weights
        self.duration = duration
        self.speed = speed
    }
    
}
