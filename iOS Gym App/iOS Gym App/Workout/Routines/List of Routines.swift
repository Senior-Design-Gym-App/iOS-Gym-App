import SwiftUI
import SwiftData

struct WorkoutRoutineListView: View {
    
    @Query private var grouos: [WorkoutGroup]
    @Query private var routines: [WorkoutRoutine]
    @AppStorage("viewType") private var viewType: ViewTypes = .list
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @AppStorage("routineSortMethod") private var routineSortMethod: RoutineSortMethod = .alphabetical
    
    private var sortedRoutines: [WorkoutRoutine] {
        switch routineSortMethod {
        case .alphabetical:
            routines.sorted { $0.name < $1.name }
        case .created:
            routines.sorted { $0.created < $1.created }
        case .modified:
            routines.sorted { $0.modified < $1.modified }
        case .pinned:
            routines.filter { $0.pinned }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                SortPicker()
                    .padding(.horizontal)
                switch viewType {
                case .list:
                    ListView()
                case .grid:
                    GridView()
                }
            }
            .navigationTitle("Workout Routines")
            .toolbar {
                ToolbarItem {
                    ListStyle()
                        .padding(.leading, 5)
                }
                ToolbarItem {
                    NavigationLink {
                        CreateWorkoutRoutineView(allGroups: grouos)
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
                    ForEach(sortedRoutines, id: \.self) { routine in
                        NavigationLink {
                            EditWorkoutRoutineView(allGroups: grouos, pinned: routine.pinned, name: routine.name, routine: routine, selectedGroups: routine.groups ?? [])
                        } label: {
                            RoutineViews.CardView(routine: routine)
                        }
                    }
                }
            }
        }
    }
    
    private func ListView() -> some View {
        List {
            ForEach(sortedRoutines, id: \.self) { routine in
                NavigationLink {
                    EditWorkoutRoutineView(allGroups: grouos, pinned: routine.pinned, name: routine.name, routine: routine, selectedGroups: routine.groups ?? [])
                } label: {
                    HStack {
                        if let image = routine.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 70, height: 70)
                                .foregroundStyle(routine.color)
                        }
                        VStack(alignment: .leading) {
                            Text(routine.name)
                        }
                    }
                }
            }
        }
    }
    
    private func ListStyle() -> some View {
        Picker("View Type", selection: $viewType) {
            Label("List", systemImage: "list.bullet").tag(ViewTypes.list)
            Label("Grid", systemImage: "square.grid.2x2").tag(ViewTypes.grid)
        }
        .pickerStyle(.segmented)
    }
    
    private func SortPicker() -> some View {
        Picker("Sort & Filter", selection: $routineSortMethod) {
            ForEach(RoutineSortMethod.allCases, id: \.self) { method in
                Text(method.rawValue).tag(method)
            }
        }
        .pickerStyle(.segmented)
    }
    
}

enum RoutineSortMethod: String, CaseIterable, Identifiable {
    
    case alphabetical       = "A-Z"
    case created            = "Created"
    case modified           = "Modified"
    case pinned             = "Pinned"
    
    var id : String { rawValue }
    
}

enum ViewTypes: String, CaseIterable, Identifiable {
    
    case list               = "List"
    case grid               = "Grid"
    
    var id : String { rawValue }
}
