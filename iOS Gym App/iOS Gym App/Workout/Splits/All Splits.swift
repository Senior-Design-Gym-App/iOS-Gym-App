import SwiftUI
import SwiftData

struct AllWorkoutSplitsView: View {
    
    @Query private var allDays: [WorkoutDay]
    @Query private var allSplits: [WorkoutSplit]
    
    @State private var showAddSplit: Bool = false
    
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    private var sortedSplits: [WorkoutSplit] {
        allSplits.sorted {
            if $0.pinned == $1.pinned {
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            return $0.pinned && !$1.pinned
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                GridView()
            }
            .navigationTitle("My Splits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSplit = true
                    } label: {
                        Label("Create Split", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSplit) {
                CreateWorkoutSplitView(allDays: allDays)
            }
        }
    }
    
    private func GridView() -> some View {
        GlassEffectContainer {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(sortedSplits, id: \.self) { split in
                        NavigationLink {
                            EditWorkoutSplitView(allDays: allDays, pinned: split.pinned, name: split.name, selectedImage: split.image, split: split, selectedDays: split.days ?? [])
                        } label: {
                            ReusedPreviews.GridSplitView(split: split)
                        }
                    }
                }
            }
        }
    }
    
}
