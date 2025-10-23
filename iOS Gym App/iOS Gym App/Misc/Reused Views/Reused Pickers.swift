import SwiftUI

struct ReusedPickers {
    
    static func ViewTypePicker(viewType: Binding<WorkoutViewTypes>) -> some View {
        Picker("View Type", selection: viewType) {
            ForEach(WorkoutViewTypes.allCases, id: \.self) { type in
                Label(type.rawValue, systemImage: type.imageName).tag(type)
            }
        }
    }
    
}
