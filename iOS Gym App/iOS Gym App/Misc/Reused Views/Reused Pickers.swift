import SwiftUI

extension ReusedViews {
    
    struct Pickers {
        
        static func WorkoutMenu(sortType: Binding<WorkoutSortTypes>, viewType: Binding<WorkoutViewTypes>) -> some View {
            Menu {
                Picker("View Type", selection: viewType) {
                    ForEach(WorkoutViewTypes.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.imageName).tag(type)
                    }
                }
                Picker("Sort Method", selection: sortType) {
                    Text("A-Z").tag(WorkoutSortTypes.alphabetical)
                    Text("Created").tag(WorkoutSortTypes.created)
                    Text("Modified").tag(WorkoutSortTypes.modified)
                }
            } label: {
                Label("Options", systemImage: "ellipsis")
            }
        }
        
        static func TimerTypePicker(type: Binding<TimerType>) -> some View {
            Picker("Timer Type", selection: type) {
                ForEach(TimerType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.imageName).tag(type)
                }
            }
        }
        
        static func DisplayTypePicker(type: Binding<DonutDisplayType>, exempt: DonutDisplayType) -> some View {
            Picker("Displayed Data", selection: type) {
                ForEach(DonutDisplayType.allCases, id: \.self) { type in
                    if type != exempt {
                        Text(type.rawValue).tag(type)
                    }
                }
            }.pickerStyle(.segmented)
        }
        
    }
    
}
