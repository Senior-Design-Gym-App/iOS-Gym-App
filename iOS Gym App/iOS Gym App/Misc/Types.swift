//
//  Types.swift
//  iOS Gym App
//
//  Created by Matthew Jacobs on 10/8/25.
//

import Foundation

struct WeightEntry: Hashable, Identifiable, Codable, Equatable {
    var id: Int { index }
    let index: Int
    let value: Double
    let date: Date
}
