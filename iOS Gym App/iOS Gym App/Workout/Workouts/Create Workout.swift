import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    
    @State private var showAddSheet: Bool = false
    @State private var showAISheet: Bool = false
    @State private var newWorkout = Workout(name: "New Workout", exercises: [])
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @AppStorage("defaultHour") private var defaultHour: Int = 8
    @AppStorage("defaultMinute") private var defaultMinute: Int = 0
    @AppStorage("defaultPeriod") private var defaultPeriod: DayPeriod = .am
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Spacer()
                    VStack {
                        ReusedViews.Labels.LargeIconSize(color: newWorkout.color)
                            .offset(y: Constants.largeOffset)
                        HStack {
                            ReusedViews.Buttons.RenameButtonAlert(type: .workout, oldName: $newWorkout.name)
                            ReusedViews.WorkoutViews.NotificationDatePicker(workout: $newWorkout, type: newWorkout.notificationType?.type ?? .disabled, period: newWorkout.notificationType?.period ?? defaultPeriod, hour: newWorkout.notificationType?.hour ?? defaultHour, minute: newWorkout.notificationType?.minute ?? defaultMinute, weekDay: newWorkout.notificationType?.day ?? .monday)
                        }
                    }
                    Spacer()
                }.padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                SelectedExerciseList()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    ReusedViews.Buttons.CancelButton(cancel: Dismiss)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAISheet = true
                    } label: {
                        Label("AI Generate", systemImage: "sparkles")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    ReusedViews.Buttons.SaveButton(disabled: newWorkout.name.isEmpty, save: Save)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.WorkoutViews.WorkoutControls(newExercises: newWorkout.sortedExercises, showAddSheet: $showAddSheet, workout: $newWorkout)
            }
            .sheet(isPresented: $showAISheet) {
                AIWorkoutGenerationSheet(workout: $newWorkout, context: context)
            }
            .navigationTitle(newWorkout.name)
            .navigationSubtitle("Created Now")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func SelectedExerciseList() -> some View {
        Section {
            ForEach(newWorkout.sortedExercises, id: \.self) { exercise in
                ReusedViews.ExerciseViews.ExerciseListPreview(exercise: exercise)
            }
        } header: {
            ReusedViews.Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .workout, items: newWorkout.sortedExercises)
        }
    }
    @MainActor
    private func Save() {
        context.insert(newWorkout)
        try? context.save()
        dismiss()
    }
    
    private func Dismiss() {
        dismiss()
    }
    
}

// MARK: - AI Workout Generation Sheet

struct AIWorkoutGenerationSheet: View {
    
    @Binding var workout: Workout
    let context: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    @State private var userPrompt: String = ""
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var generatedSummary: String?
    @State private var generatedTips: [String] = []
    @State private var generatedExercises: [Exercise] = []
    @State private var workoutName: String = ""
    @State private var shouldApplyOnDismiss = false

    
    private let aiFunctions = AIFunctions()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue.gradient)
                        .padding(.top)
                    
                    Text("AI Workout Generator")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Describe your ideal workout")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                // Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("What kind of workout?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextField("e.g., upper body push, leg day, full body...", text: $userPrompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                        .padding(.horizontal)
                    
                    Text("Be specific: mention target muscles, equipment, duration, or fitness level")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                // Generate Button
                Button {
                    Task { await generateWorkout() }
                } label: {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.8)
                        }
                        Text(isGenerating ? "Generating..." : "Generate Workout")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(userPrompt.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(userPrompt.isEmpty || isGenerating)
                .padding(.horizontal)
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Summary Section
                if let summary = generatedSummary {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Summary", systemImage: "doc.text")
                                    .font(.headline)
                                
                                Text(summary)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            if !generatedTips.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Tips", systemImage: "lightbulb")
                                        .font(.headline)
                                    
                                    ForEach(generatedTips, id: \.self) { tip in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("•")
                                            Text(tip)
                                                .font(.callout)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Show generated exercises
                            if !generatedExercises.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Exercises (\(generatedExercises.count))", systemImage: "figure.strengthtraining.traditional")
                                        .font(.headline)
                                    
                                    ForEach(generatedExercises, id: \.id) { exercise in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(exercise.name)
                                                    .font(.callout)
                                                    .fontWeight(.medium)
                                                if let muscle = exercise.muscleWorked {
                                                    Text(muscle)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            Spacer()
                                            if let sets = exercise.reps.first?.count {
                                                Text("\(sets) sets")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        shouldApplyOnDismiss = false
                        dismiss()
                    }
                    .disabled(isGenerating)
                }
                
                if !generatedExercises.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Use Workout") {
                            shouldApplyOnDismiss = true
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("AI Generator")
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled(!generatedExercises.isEmpty)
        .onDisappear {
            if shouldApplyOnDismiss {
                applyWorkout()
            }
        }
    }
    
    private func generateWorkout() async {
        isGenerating = true
        errorMessage = nil
        generatedSummary = nil
        generatedTips = []
        generatedExercises = []
        
        do {
            let result = try await aiFunctions.generateWorkout(
                workoutType: userPrompt,
                targetMuscles: nil,
                duration: nil,
                equipment: nil,
                fitnessLevel: nil,
                additionalNotes: nil
            )
            
            // Store the workout name
            workoutName = result.name
            
            // DON'T insert exercises into context yet - just store them
            generatedExercises = result.exercises
            generatedSummary = result.summary
            generatedTips = result.tips
            
            print("✅ Workout generated with \(result.exercises.count) exercises!")
            
        } catch {
            errorMessage = "Failed to generate workout: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isGenerating = false
    }
    
    private func applyWorkout() {
        print("🔄 Applying workout...")
        
        // Insert exercises into context NOW (only when user confirms)
        for exercise in generatedExercises {
            context.insert(exercise)
            print("✅ Inserted exercise: \(exercise.name)")
        }
        
        // Update workout properties BEFORE it's tracked by SwiftData
        workout.name = workoutName
        workout.exercises = generatedExercises
        workout.modified = Date()
        
        // Encode the order
        let newIDs = generatedExercises.map { $0.persistentModelID }
        workout.encodeIDs(ids: newIDs)
        
        // Save context once
        do {
            try context.save()
            print("✅ Context saved: \(workout.name) with \(workout.exercises?.count ?? 0) exercises")
        } catch {
            print("❌ Failed to save context: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    CreateWorkoutView()
        .modelContainer(for: [Workout.self, Exercise.self], inMemory: true)
}
