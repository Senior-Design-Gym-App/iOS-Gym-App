import SwiftUI
import SwiftData

struct AllWorkoutSplitsView: View {
    
    @Query private var allWorkouts: [Workout]
    @Query private var allSplits: [Split]
    
    @Namespace private var namespace
    @State private var showAddSplit: Bool = false
    @AppStorage("splitSortMethod") private var sortMethod: WorkoutSortTypes = .alphabetical
    @AppStorage("splitViewType") private var viewType: WorkoutViewTypes = .grid
    
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    
    private var sortedSplits: [Split] {
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
                switch viewType {
                case .grid:
                    GridView()
                case .verticalList:
                    VerticalListView()
                }
            }
            .navigationTitle("Splits")
            .toolbar {
                ToolbarItem {
                    Button {
                        showAddSplit = true
                    } label: {
                        Label("Create Split", systemImage: "plus")
                            .foregroundStyle(.clear)
                    }.tint(Constants.labelColor)
                }
                ToolbarItemGroup {
                    Menu {
                        ReusedPickers.ViewTypePicker(viewType: $viewType)
                        SortPicker()
                    } label: {
                        Image(systemName: "ellipsis")
                    }.tint(Constants.labelColor)
                }
            }
            .sheet(isPresented: $showAddSplit) {
                CreateWorkoutSplitView()
            }
        }
    }
    
    private func GridView() -> some View {
        GlassEffectContainer {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(sortedSplits, id: \.self) { split in
                        NavigationLink {
                            EditSplitView(allWorkouts: allWorkouts, pinned: split.pinned, name: split.name, selectedImage: split.image, split: split, selectedWorkouts: split.workouts ?? [])
                                .navigationTransition(.zoom(sourceID: split.id, in: namespace))
                        } label: {
                            ReusedViews.SplitViews2.SplitGridPreview(split: split, bottomText: "\(split.workouts?.count ?? 0) Day\(split.workouts?.count == 1 ? "" : "s")")
                                .matchedTransitionSource(id: split.id, in: namespace)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func VerticalListView() -> some View {
        List {
            ForEach(sortedSplits, id: \.self) { split in
                NavigationLink {
                    EditSplitView(allWorkouts: allWorkouts, pinned: split.pinned, name: split.name, selectedImage: split.image, split: split, selectedWorkouts: split.workouts ?? [])
                        .navigationTransition(.zoom(sourceID: split.id, in: namespace))
                } label: {
                    HStack {
                        SplitViews.CardView(split: split, size: Constants.mediumListSize)
                            .frame(width: Constants.mediumListSize, height: Constants.mediumListSize)
                        
                        ReusedViews.Description(topText: split.name, bottomText: "\(split.workouts?.count ?? 0) day\(split.workouts?.count == 1 ? "" : "s")")
                    }
                    .matchedTransitionSource(id: split.id, in: namespace)
                }
            }
        }.listStyle(.plain)
    }
    
    private func SortPicker() -> some View {
        Picker("Sort Method", selection: $sortMethod) {
            Text("A-Z").tag(WorkoutSortTypes.alphabetical)
            Text("Created").tag(WorkoutSortTypes.created)
            Text("Modified").tag(WorkoutSortTypes.modified)
        }
    }
    
}
