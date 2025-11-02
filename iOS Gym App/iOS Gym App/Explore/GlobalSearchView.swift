//
//  GlobalSearchView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI

private enum SearchCategory: String, CaseIterable, Identifiable {
    case users = "Users"
    case workouts = "Workouts"
    case sessions = "Sessions"
    case gyms = "Gyms"
    var id: String { rawValue }
}

struct GlobalSearchView: View {
    @State private var query: String = ""
    @State private var activeCategories: Set<SearchCategory> = Set(SearchCategory.allCases)

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search users, workouts, sessions, gyms", text: $query)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                if !query.isEmpty {
                    Button(action: { query = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.systemGray6)))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(.separator)))
            .padding([.horizontal, .top])

            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SearchCategory.allCases) { cat in
                        let isOn = activeCategories.contains(cat)
                        Button(action: {
                            if isOn { activeCategories.remove(cat) } else { activeCategories.insert(cat) }
                        }) {
                            Text(cat.rawValue)
                                .font(.footnote.weight(.semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(isOn ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color(.separator))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }

            Divider()

            // Results
            List {
                if activeCategories.contains(.users) {
                    Section("Users") {
                        ForEach(sampleUsers.filter { matches($0) }, id: \.self) { name in
                            HStack {
                                Image(systemName: "person.crop.circle.fill").foregroundStyle(.secondary)
                                Text(name)
                            }
                        }
                    }
                }
                if activeCategories.contains(.workouts) {
                    Section("Workouts") {
                        ForEach(sampleWorkouts.filter { matches($0.title) }, id: \.title) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title).font(.headline)
                                Text(item.detail).font(.subheadline).foregroundStyle(.secondary)
                                HStack {
                                    Spacer()
                                    ShareLink(item: item.shareText) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
                if activeCategories.contains(.sessions) {
                    Section("Sessions") {
                        ForEach(sampleSessions.filter { matches($0.title) }, id: \.title) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title).font(.headline)
                                Text(item.detail).font(.subheadline).foregroundStyle(.secondary)
                                HStack {
                                    Spacer()
                                    ShareLink(item: item.shareText) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
                if activeCategories.contains(.gyms) {
                    Section("Gyms") {
                        ForEach(sampleGyms.filter { matches($0) }, id: \.self) { name in
                            HStack {
                                Image(systemName: "mappin.and.ellipse").foregroundStyle(.secondary)
                                Text(name)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Search")
        .toolbarTitleDisplayMode(.inline)
    }

    private func matches(_ text: String) -> Bool {
        guard !query.isEmpty else { return true }
        return text.localizedCaseInsensitiveContains(query)
    }
}

// MARK: - Sample Data
private let sampleUsers = ["aaron", "matt", "troy", "demo_user", "sarah"]

private struct ShareItem: Hashable { let title: String; let detail: String; var shareText: String { "Workout: \(title) — \(detail)" } }
private let sampleWorkouts: [ShareItem] = [
    .init(title: "Push Day", detail: "Bench • OHP • Triceps"),
    .init(title: "Legs A", detail: "Squat • RDL • Lunges")
]
private let sampleSessions: [ShareItem] = [
    .init(title: "Jan 3 Session", detail: "Chest/Back • 62 min"),
    .init(title: "Jan 5 Session", detail: "Legs • 54 min")
]
private let sampleGyms = ["Anytime Fitness", "Gold's Gym", "Powerhouse"]


