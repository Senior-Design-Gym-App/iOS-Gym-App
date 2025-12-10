import SwiftUI
import SwiftData

extension ReusedViews {
    
    struct WorkoutViews {
        
        static func WorkoutListPreview(workout: Workout) -> some View {
            Label {
                Text(workout.name)
                Text("\(workout.sortedExercises.count) exercises\(workout.sortedExercises.count == 1 ? "" : "s")")
            } icon: {
                Labels.ListIcon(color: workout.color)
            }
        }
        
        static func HorizontalListPreview(workout: Workout) -> some View {
            VStack(alignment: .leading, spacing: 5) {
                Labels.MediumIconSize(color: workout.color)
                Labels.TypeListDescription(name: workout.name, items: workout.sortedExercises, type: .workout)
            }
        }
        
        struct WorkoutControls: View {
            
            @Query private var allExercises: [Exercise]
            @State var newExercises: [Exercise]
            @Binding var showAddSheet: Bool
            @Binding var workout: Workout
            
            var body: some View {
                NavigationStack {
                    List {
                        Section {
                            ForEach(newExercises, id: \.self) { exercise in
                                ExerciseViews.ExerciseListPreview(exercise: exercise).id(exercise.id)
                            }
                            .onMove { indices, newOffset in
                                newExercises.move(fromOffsets: indices, toOffset: newOffset)
                            }
                            .onDelete { indices in
                                newExercises.remove(atOffsets: indices)
                            }
                        } header: {
                            Text("Current Exercises")
                        }
                        Section {
                            ForEach(allExercises.filter { !newExercises.contains($0) }
                                .sorted { $0.name < $1.name }
                                    , id: \.self) { exercise in
                                HStack {
                                    ExerciseViews.ExerciseListPreview(exercise: exercise)
                                    Spacer()
                                    Button {
                                        withAnimation {
                                            newExercises.append(exercise)
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle")
                                    }
                                }.id(exercise.id)
                            }
                        } header: {
                            Text("All Exercises")
                        }
                    }
                    .environment(\.editMode, .constant(.active))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            ReusedViews.Buttons.CancelButton(cancel: CancelOptions)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            ReusedViews.Buttons.SaveButton(disabled: newExercises.isEmpty, save: SaveOptions)
                        }
                    }
                }
            }
            
            private func SaveOptions() {
                workout.exercises = newExercises
                if let exercises = workout.exercises {
                    let newIDs = exercises.map { $0.persistentModelID }
                    workout.encodeIDs(ids: newIDs)
                }
                workout.modified = Date()
                showAddSheet = false
            }
            
            private func CancelOptions() {
                showAddSheet = false
            }
            
        }
        
        struct NotificationDatePicker: View {
            
            @Binding var workout: Workout
            @State var type: NotificationType
            @State var period: DayPeriod
            @State var hour: Int
            @State var minute: Int
            @State var weekDay: DayofWeek
            
            var adjustedType: WorkoutNotificationType {
                WorkoutNotificationType(type: type, period: period, day: weekDay, minute: minute, hour: hour)
            }
            
            var body: some View {
                Menu {
                    Section {
                        Picker("Notificaiton Type", selection: $type) {
                            ForEach(NotificationType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                    Picker("Day", selection: $period) {
                        ForEach(DayofWeek.allCases, id: \.self) { day in
                            Text(day.rawValue.capitalized).tag(day)
                        }
                    }.pickerStyle(.palette)
                    if type == .weekly {
                        Section {
                            ReusedViews.Pickers.WorkoutNotificationPicker(hour: $hour, minute: $minute, period: $period)
                                .pickerStyle(.palette)
                        }
                    }
                } label: {
                    Label("Notification Time", systemImage: type != .disabled ? "bell.badge" : "bell.badge.slash")
                        .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
                        .labelStyle(.iconOnly)
                }
                .menuActionDismissBehavior(.disabled)
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
                .onChange(of: adjustedType) {
                    workout.encodeNotificationType(type: adjustedType)
                    if let split = workout.split, adjustedType.type == .weekly {
                        NotificationManager.instance.ScheduleNotificationsForSplit(split: split)
                    }
                }
            }
            
        }
        
        static func MostRecentSession(workout: Workout) -> String {
            if let sessions = workout.sessions,
               let recent = sessions.compactMap({ $0.completed }).sorted(by: { $0 > $1 }).first {
                return DateHandler().RelativeTime(from: recent)
            } else {
                return "No Sessions"
            }
        }
        
    }
    
}

extension Workout {
    
    func encode() {
        notificationString = ""
    }
    
}
