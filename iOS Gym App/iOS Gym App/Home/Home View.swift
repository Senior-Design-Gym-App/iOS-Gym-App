import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    GreetingHeader(name: "Ohtani")
                    QuickActions()
                    StatsGrid()
                    RecentWorkouts()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Home")
        }
    }
}

private struct GreetingHeader: View {
    let name: String
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning").font(.subheadline).foregroundStyle(.secondary)
                Text("\(name) 👋").font(.system(size: 28, weight: .bold))
            }
            Spacer()
            StreakPill(streak: 5)
        }
        .padding(16)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 6, y: 3)
    }
}

private struct StreakPill: View {
    let streak: Int
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
            Text("\(streak) day streak")
        }
        .font(.footnote.weight(.semibold))
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color.accentColor.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct QuickActions: View {
    var body: some View {
        HStack(spacing: 12) {
            PrimaryButton(title: "Start Workout", icon: "play.fill") {
                // TODO: Navigate to your existing workout entry point (e.g., WorkoutHome or ActiveWorkoutView)
            }
            SecondaryButton(title: "Plan", icon: "calendar") {
                // TODO: Navigate to your planning/program screen
            }
        }
    }
}

private struct StatsGrid: View {
    var body: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
            StatTile(title: "Volume", value: "12.4k", subtitle: "lbs this week", icon: "scalemass")
            StatTile(title: "Sessions", value: "4", subtitle: "this week", icon: "figure.strengthtraining.functional")
            StatTile(title: "PRs", value: "2", subtitle: "last 30 days", icon: "rosette")
            StatTile(title: "Time", value: "3h 10m", subtitle: "this week", icon: "clock.arrow.circlepath")
        }
    }
}

private struct RecentWorkouts: View {
    struct Item: Identifiable { let id = UUID(); let title: String; let when: String; let duration: Int; let volume: Int }
    let items: [Item] = [
        .init(title: "Push – Chest & Triceps", when: "Yesterday", duration: 56, volume: 3200),
        .init(title: "Pull – Back & Biceps",   when: "Mon",       duration: 48, volume: 2900),
        .init(title: "Legs – Squat Focus",     when: "Sat",       duration: 62, volume: 4100),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Workouts").font(.title3.weight(.bold))
                Spacer()
                NavigationLink("See all") { Text("All Workouts (placeholder)") }
                    .font(.footnote.weight(.semibold))
            }
            ForEach(items) { item in
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.accentColor.opacity(0.12))
                        Image(systemName: "dumbbell.fill")
                    }
                    .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title).font(.headline)
                        HStack(spacing: 12) {
                            Label("\(item.duration)m", systemImage: "clock")
                            Label("\(item.volume) lb", systemImage: "scalemass")
                            Text(item.when).foregroundStyle(.secondary)
                        }
                        .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                }
                .padding(14)
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(radius: 4, y: 2)
            }
        }
    }
}
