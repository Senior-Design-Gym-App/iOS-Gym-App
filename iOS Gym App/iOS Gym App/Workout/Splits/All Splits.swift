import SwiftUI
import SwiftData

struct AllWorkoutSplitsView: View {
    
    @Query private var allDays: [WorkoutDay]
    @Query private var allSplits: [WorkoutSplit]
    
    @AppStorage("routineViewType") private var routineViewType: WorkoutViewTypes = .verticalList
    
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
                switch routineViewType {
                case .verticalList, .horizontalList:
                    ListView()
                case .grid:
                    GridView()
                }
            }
            .navigationTitle("My Splits")
            .toolbar {
                ToolbarItem {
                    ListStyle()
                        .padding(.leading, 5)
                }
                ToolbarItem {
                    NavigationLink {
                        CreateWorkoutSplitView(allDays: allDays)
                    } label: {
                        Label("Create Routine", systemImage: "plus")
                    }
                }
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
                            SplitViews.CardViewOverlay(split: split)
                        }
                    }
                }
            }
        }
    }
    
    private func ListView() -> some View {
        List {
            ForEach(sortedSplits, id: \.self) { split in
                NavigationLink {
                    EditWorkoutSplitView(allDays: allDays, pinned: split.pinned, name: split.name, selectedImage: split.image, split: split, selectedDays: split.days ?? [])
                } label: {
                    HStack {
                        SplitViews.CardView(split: split, size: 50)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(split.name)
                                .font(.headline)
                            Text("Created: \(split.created, formatter: DateHandler().dateFormatter())")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Modified: \(split.modified, formatter: DateHandler().dateFormatter())")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    private func ListStyle() -> some View {
        Picker("View Type", selection: $routineViewType) {
            Label(WorkoutViewTypes.verticalList.rawValue, systemImage: WorkoutViewTypes.verticalList.imageName).tag(WorkoutViewTypes.verticalList)
            Label(WorkoutViewTypes.grid.rawValue, systemImage: WorkoutViewTypes.grid.imageName).tag(WorkoutViewTypes.grid)
        }
        .pickerStyle(.segmented)
    }
    
}
