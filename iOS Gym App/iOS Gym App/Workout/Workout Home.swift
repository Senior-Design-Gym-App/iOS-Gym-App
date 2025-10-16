import SwiftUI
import SwiftData

struct WorkoutHome: View {
    
    @Query private var workouts: [Workout]
    @Query private var days: [WorkoutDay]
    @Query private var splits: [WorkoutSplit]
    
    var body: some View {
        NavigationStack {
            List {
                WorkoutHeader()
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                MyWorkoutSection()
            }
            .ignoresSafeArea(edges: .top)
            .listStyle(.plain)
            .navigationTitle("Title")
            .navigationSubtitle("Subtitle 1")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func WorkoutHeader() -> some View {
        ZStack {
            ReusedViews.HeaderCard(fill: Constants.mainAppTheme)
            VStack(spacing: 0) {
                Spacer()
                ReusedViews.HeaderTitle(title: "Subtitle 2")
                ReusedViews.HeaderSubtitle(subtitle: "Subtitle 3")
                Spacer()
            }
        }
    }
    
    private func MyWorkoutSection() -> some View {
        Section {
            NavigationLink {
                AllWorkoutsView()
            } label: {
                Label("Workouts", systemImage: "dumbbell")
            }
            NavigationLink {
                AllWorkoutDaysView()
            } label: {
                Label("Workout Days", systemImage: "tag")
            }
            NavigationLink {
                AllWorkoutSplitsView()
            } label: {
                Label("Workout Splits", systemImage: "calendar.day.timeline.left")
            }
        } header: {
            Label("My Workouts", systemImage: "checklist")
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
