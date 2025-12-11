//
//  ProfileLabels.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/10/25.
//

import SwiftUI

struct ProfileLabels {
    
    /// List icon with color
    static func ListIcon(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(color)
            .frame(width: 32, height: 32)
            .overlay {
                Image(systemName: "dumbbell")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }
    }
    
    /// Medium-sized icon
    static func MediumIconSize(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(color)
            .frame(width: 44, height: 44)
            .overlay {
                Image(systemName: "dumbbell")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
            }
    }
    
    /// Type list description (shows name and item count)
    static func TypeListDescription(name: String, items: [Exercise], type: ListType) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
            Text("\(items.count) \(type.rawValue)\(items.count == 1 ? "" : "s")")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    enum ListType: String {
        case workout = "exercise"
        case exercise = "set"
    }
}
