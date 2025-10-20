//
//  Buttons.swift
//  iOS Gym App
//
//  Created by Aaron on 10/21/25.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack { Image(systemName: icon); Text(title).fontWeight(.semibold) }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack { Image(systemName: icon); Text(title).fontWeight(.semibold) }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.accentColor.opacity(0.35), lineWidth: 1.25)
                )
        }
    }
}
