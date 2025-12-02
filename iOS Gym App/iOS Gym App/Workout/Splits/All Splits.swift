import SwiftUI
import SwiftData

struct AllWorkoutSplitsView: View {
    
    let allSplits: [Split]
    let allWorkouts: [Workout]
    let allExercises: [Exercise]
    
    @Namespace private var namespace
    @State private var showAddSplit: Bool = false
    @AppStorage("splitSortMethod") private var sortType: WorkoutSortTypes = .alphabetical
    @AppStorage("splitViewType") private var viewType: WorkoutViewTypes = .grid
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    private var sortedSplits: [Split] {
        switch sortType {
        case .alphabetical:
            allSplits.sorted { $0.name < $1.name }
        case .created:
            allSplits.sorted { $0.created > $1.created }
        case .modified:
            allSplits.sorted { $0.modified < $1.modified }
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
                    ReusedViews.Buttons.CreateButton(toggleCreateSheet: $showAddSplit)
                }
                ToolbarItem {
                    ReusedViews.Pickers.WorkoutMenu(sortType: $sortType, viewType: $viewType)
                }
            }
            .sheet(isPresented: $showAddSplit) {
                CreateWorkoutSplitView(allWorkouts: allWorkouts, allExercises: allExercises)
            }
        }
    }
    
    private func GridView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(sortedSplits, id: \.self) { split in
                    NavigationLink {
                        EditSplitView(selectedImage: split.image, selectedSplit: split)
                            .navigationTransition(.zoom(sourceID: split.id, in: namespace))
                    } label: {
                        ReusedViews.SplitViews.HorizontalListPreview(split: split)
                            .matchedTransitionSource(id: split.id, in: namespace)
                    }.buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func VerticalListView() -> some View {
        List {
            ForEach(sortedSplits, id: \.self) { split in
                NavigationLink {
                    EditSplitView(selectedImage: split.image, selectedSplit: split)
                } label: {
                    ReusedViews.SplitViews.ListPreview(split: split)
                }
            }
        }
    }
    
}
