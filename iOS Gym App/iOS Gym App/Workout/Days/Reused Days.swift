import SwiftUI

struct DayOptionsView: View {
    
    let allWorkouts: [Workout]
    @Binding var name: String
    @Binding var selectedWorkouts: [Workout]
    
    @State private var showRename = false
    
    var body: some View {
        GlassEffectContainer {
            List {
                Section {
                    DayHeader()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                RoutineGroups()
            }
            .alert("Day Name", isPresented: $showRename) {
                TextField("Enter day name", text: $name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                Button("Ok", role: .confirm) {
                }
            }
        }
    }
    
    private func DayHeader() -> some View {
        VStack {
            Image(systemName: "circle.fill")
                .resizable()
                .scaledToFill()
                .padding(.horizontal, Constants.headerPadding)
                .foregroundStyle(Constants.mainAppTheme)
            ReusedViews.HeaderTitle(title: name)
            let tags: [MuscleGroup] = selectedWorkouts.compactMap { $0.muscleInfo?.group }
            ReusedViews.HeaderSubtitle(subtitle: GetTagSubtitle(tags: tags))
            DayRename()
        }.frame(maxWidth: .infinity)
    }
    
    private func RoutineGroups() -> some View {
        Section {
            ForEach($selectedWorkouts, id: \.self) { workout in
                Text(workout.name.wrappedValue)
            }
            .onDelete { indices in
                $selectedWorkouts.wrappedValue.remove(atOffsets: indices)
            }
            .onMove { indices, newOffset in
                $selectedWorkouts.wrappedValue.move(fromOffsets: indices, toOffset: newOffset)
            }
        } header: {
            AddWorkoutHeader()
        }
    }
    
    private func AddWorkoutHeader() -> some View {
        HStack {
            Label("Workouts", systemImage: "dumbbell")
            Spacer()
            Menu {
                ForEach(allWorkouts.sorted(by: { $0.name < $1.name })) { workout in
                    Button {
                        $selectedWorkouts.wrappedValue.append(workout)
                    } label: {
                        Text(workout.name)
                    }
                }
            } label: {
                Label("Add to Day", systemImage: "plus")
            }
        }
    }
    
    private func GetTagSubtitle(tags: [MuscleGroup]) -> String {
        let allTags = tags.map(\.rawValue).joined(separator: " | ")
        return "\(allTags.isEmpty ? "No Tags" : allTags)"
    }
    
    private func DayRename() -> some View {
        Button {
            showRename = true
        } label: {
            CustomLabelView(text: "Rename", image: "pencil")
        }.buttonStyle(.glass)
    }
    
}
