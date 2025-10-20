//
//  StatTile.swift
//  iOS Gym App
//
//  Created by Aaron on 10/21/25.
//

import SwiftUI

struct StatTile: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title).font(.subheadline).foregroundStyle(.secondary)
            }
            Text(value).font(.system(size: 26, weight: .bold))
            Text(subtitle).font(.caption).foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 3, y: 2)
    }
}
