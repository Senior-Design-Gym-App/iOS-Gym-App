import SwiftUI

struct DayViews {
    
    static func Header() -> some View {
        Rectangle()
            .foregroundStyle(Constants.mainAppTheme)
            .aspectRatio(Constants.headerRatio ,contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .clipped()
    }
    
    static func RoutineGroups(selectedWorkouts: Binding<[Workout]>, allWorkouts: [Workout]) -> some View {
        Section {
            ForEach(selectedWorkouts, id: \.self) { workout in
                Text(workout.name.wrappedValue)
            }
            .onDelete { indices in
                selectedWorkouts.wrappedValue.remove(atOffsets: indices)
            }
            .onMove { indices, newOffset in
                selectedWorkouts.wrappedValue.move(fromOffsets: indices, toOffset: newOffset)
            }
        } header: {
            AddWorkoutHeader(selectedWorkouts: selectedWorkouts, allWorkouts: allWorkouts)
        }
    }
    
    static private func AddWorkoutHeader(selectedWorkouts: Binding<[Workout]>, allWorkouts: [Workout]) -> some View {
        HStack {
            Label("Workouts", systemImage: "dumbbell")
            Spacer()
            Menu {
                ForEach(allWorkouts.sorted(by: { $0.name < $1.name })) { workout in
                    Button {
                        selectedWorkouts.wrappedValue.append(workout)
                    } label: {
                        Text(workout.name)
                    }
                }
            } label: {
                Label("Add to Day", systemImage: "plus")
            }
        }
    }
    
    static func Info(day: WorkoutDay) -> some View {
        HStack {
            Circle()
                .fill(day.color)
                    .frame(maxWidth: 20, maxHeight: 20)
            VStack(alignment: .leading, spacing: 0) {
                Text(day.name)
                    .font(.headline)
                let allTags = day.tags.map(\.rawValue).joined(separator: ", ")
                Text("\(allTags.isEmpty ? "No Tags" : allTags)")
                    .font(.subheadline)
            }
        }
    }
    
    static func GetTagSubtitle(tags: [MuscleGroup]) -> String {
        let allTags = tags.map(\.rawValue).joined(separator: ", ")
        return "\(allTags.isEmpty ? "No Tags" : allTags)"
    }

}

struct DayOptionsView: View {
    
    @Binding var name: String
    @State private var showRename = false
    
    var body: some View {
        DayRename()
        .alert("Change Username", isPresented: $showRename) {
            TextField("Enter new username", text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Cancel", role: .cancel) {
                name = ""
            }
            Button("Ok", role: .confirm) {
                
            }
        }
    }
    
    private func DayRename() -> some View {
        Button {
            showRename = true
        } label: {
            Label("Rename Day", systemImage: "pencil")
//                .labelStyle(.titleOnly)
                .foregroundStyle(.white)
        }.buttonStyle(.glass)
            .pickerStyle(.menu)
    }
    
}
