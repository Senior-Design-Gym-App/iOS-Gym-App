import SwiftUI
import SwiftData

struct WorkoutHome: View {
    
    @Query private var workouts: [Workout]
    @Query private var days: [WorkoutDay]
    @Query private var splits: [WorkoutSplit]
    
    var recentItems: [RecentWorkoutItem] {
        let allItems: [RecentWorkoutItem] =
            days.map { .day($0) } + splits.map { .split($0) }

        return allItems.sorted { $0.created > $1.created }
    }
    
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    
    var body: some View {
        NavigationStack {
            List {
                MyWorkoutSection()
                RecentlyAddedSection()
                    .padding(.top)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("Workouts")
        }
    }
    
    private func MyWorkoutSection() -> some View {
        Section {
            NavigationLink {
                AllWorkoutsView()
            } label: {
                Label("Workouts", systemImage: Constants.workoutIcon)
            }
            NavigationLink {
                AllWorkoutDaysView()
            } label: {
                Label("Workout Days", systemImage: Constants.workoutDayIcon)
            }
            NavigationLink {
                AllWorkoutSplitsView()
            } label: {
                Label("Workout Splits", systemImage: Constants.workoutSplitIcon)
            }
        }
    }
    
    private func RecentlyAddedSection() -> some View {
        VStack {
            ReusedViews.HorizontalHeader(text: "Recently Added", showNavigation: false)
            LazyVGrid(columns: columns) {
                ForEach(recentItems, id: \.self) { item in
                    switch item {
                    case .day(let day):
                        NavigationLink {
                            
                        } label: {
                            ReusedPreviews.GridDayView(day: day)
                        }.navigationLinkIndicatorVisibility(.hidden)
                    case .split(let split):
                        NavigationLink {
                            
                        } label: {
                            ReusedPreviews.GridSplitView(split: split)
                        }.navigationLinkIndicatorVisibility(.hidden)
                    }
                }
            }
        }
    }
    
    private func OthersRoutinesSection() -> some View {
        Section {
            NavigationLink {
                
            } label: {
                Label("Shared with me", systemImage: "sharedwithyou")
            }
            NavigationLink {
                
            } label: {
                Label("Share Routines", systemImage: "square.and.arrow.up")
            }
            NavigationLink {
                
            } label: {
                Label("AI Routines & Groups", systemImage: "apple.intelligence")
            }
        } header: {
            Text("Friend Routines")
        }
    }
    
}
