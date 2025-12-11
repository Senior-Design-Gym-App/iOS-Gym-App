//
//  GlobalSearchView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI
import SwiftData

private enum SearchCategory: String, CaseIterable, Identifiable {
    case users = "Users"
    case workouts = "Workouts"
//    case sessions = "Sessions"
//    case gyms = "Gyms"
    var id: String { rawValue }
}

struct GlobalSearchView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var query: String = ""
    @State private var activeCategories: Set<SearchCategory> = Set(SearchCategory.allCases)
    
    // Search results
    @State private var userResults: [UserProfile] = []
    @State private var workoutResults: [Workout] = []
    @State private var isSearchingUsers = false
    @State private var isSearchingWorkouts = false
    @State private var searchError: String?
    
    // Debounce task
    @State private var searchTask: Task<Void, Never>?
    
    private let cloudManager = CloudManager.shared
    private let fieldCornerRadius = Constants.cornerRadius + 4
    private let chipSpacing = Constants.customLabelPadding
    private let primaryTint = Constants.mainAppTheme

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack(spacing: chipSpacing) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search users, workouts", text: $query)
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
            .background(
                RoundedRectangle(cornerRadius: fieldCornerRadius, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: fieldCornerRadius, style: .continuous)
                    .stroke(Color(.separator))
            )
            .padding([.horizontal, .top])

            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: chipSpacing) {
                    ForEach(SearchCategory.allCases) { cat in
                        let isOn = activeCategories.contains(cat)
                        Button(action: {
                            if isOn { activeCategories.remove(cat) } else { activeCategories.insert(cat) }
                        }) {
                            Text(cat.rawValue)
                                .font(.footnote.weight(.semibold))
                                .padding(.vertical, chipSpacing)
                                .padding(.horizontal, Constants.titlePadding * 2)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(isOn ? primaryTint.opacity(0.15) : Color(.systemGray6))
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
                        if isSearchingUsers {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        } else if query.isEmpty {
                            Text("Enter a search query to find users")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                                .padding()
                        } else if userResults.isEmpty {
                            Text("No users found")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                                .padding()
                        } else {
                            ForEach(userResults) { user in
                                NavigationLink {
                                    UserProfileView(
                                        profile: UserProfileContent(
                                            username: user.username,
                                            displayName: user.displayName
                                        ),
                                        userId: user.id
                                    )
                                    .environmentObject(authManager)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "person.crop.circle.fill")
                                            .foregroundStyle(.secondary)
                                            .font(.title2)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("@\(user.username)")
                                                .font(.body)
                                            if !user.displayName.isEmpty {
                                                Text(user.displayName)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if activeCategories.contains(.workouts) {
                    Section("Workouts") {
                        if isSearchingWorkouts {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        } else if query.isEmpty {
                            Text("Enter a search query to find workouts")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                                .padding()
                        } else if workoutResults.isEmpty {
                            Text("No workouts found")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                                .padding()
                        } else {
                            ForEach(workoutResults) { workout in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(workout.name)
                                        .font(.headline)
                                    if let exercises = workout.exercises, !exercises.isEmpty {
                                        Text("\(exercises.count) exercise\(exercises.count == 1 ? "" : "s")")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    if !workout.tags.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 6) {
                                                ForEach(workout.tags.prefix(3), id: \.self) { tag in
                                                    Text(tag.rawValue)
                                                        .font(.caption2)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(tag.colorPalette.opacity(0.2))
                                                        .foregroundStyle(tag.colorPalette)
                                                        .clipShape(Capsule())
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
//                if activeCategories.contains(.sessions) {
//                    Section("Sessions") {
//                        Text("Coming soon")
//                            .foregroundStyle(.secondary)
//                            .font(.subheadline)
//                            .padding()
//                    }
//                }
//                if activeCategories.contains(.gyms) {
//                    Section("Gyms") {
//                        Text("Coming soon")
//                            .foregroundStyle(.secondary)
//                            .font(.subheadline)
//                            .padding()
//                    }
//                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Search")
        .toolbarTitleDisplayMode(.inline)
        .onAppear {
            cloudManager.setAuthManager(authManager)
        }
        .onChange(of: query) { _, newValue in
            // Cancel previous search task
            searchTask?.cancel()
            
            // Clear results if query is empty
            if newValue.isEmpty {
                userResults = []
                workoutResults = []
                return
            }
            
            // Debounce search - wait 0.5 seconds after user stops typing
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Check if task was cancelled
                guard !Task.isCancelled else { return }
                
                // Perform search
                await performSearch(query: newValue)
            }
        }
        .onChange(of: activeCategories) { _, _ in
            // Re-trigger search when categories change (if query exists)
            if !query.isEmpty {
                searchTask?.cancel()
                searchTask = Task {
                    await performSearch(query: query)
                }
            }
        }
    }
    
    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            userResults = []
            workoutResults = []
            return
        }
        
        // Search users if category is active
        if activeCategories.contains(.users) {
            await searchUsers(query: query)
        }
        
        // Search workouts if category is active
        if activeCategories.contains(.workouts) {
            await searchWorkouts(query: query)
        }
    }
    
    private func searchUsers(query: String) async {
        guard authManager.isAuthenticated, query.count >= 2 else {
            userResults = []
            return
        }
        
        isSearchingUsers = true
        searchError = nil
        
        do {
            let results = try await cloudManager.searchUsers(query: query)
            await MainActor.run {
                userResults = results
                isSearchingUsers = false
            }
        } catch {
            await MainActor.run {
                print("❌ Search users error: \(error)")
                searchError = error.localizedDescription
                userResults = []
                isSearchingUsers = false
            }
        }
    }
    
    private func searchWorkouts(query: String) async {
        guard authManager.isAuthenticated else {
            workoutResults = []
            return
        }
        
        isSearchingWorkouts = true
        searchError = nil
        
        do {
            // Fetch all public workouts (API doesn't support query parameter)
            let allWorkouts = try await cloudManager.fetchPublicWorkouts()
            
            // Filter on client side
            let filtered = allWorkouts.filter { workout in
                workout.name.localizedCaseInsensitiveContains(query) ||
                workout.tags.contains { $0.rawValue.localizedCaseInsensitiveContains(query) }
            }
            
            await MainActor.run {
                workoutResults = filtered
                isSearchingWorkouts = false
            }
        } catch {
            await MainActor.run {
                print("❌ Search workouts error: \(error)")
                searchError = error.localizedDescription
                workoutResults = []
                isSearchingWorkouts = false
            }
        }
    }
}




