import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    
    @State private var showAddSheet: Bool = false
    @State private var showAISheet: Bool = false
    @State private var newWorkout = Workout(name: "New Workout", exercises: [])
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
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
    
    private let aiFunctions = AIFunctions()
    
    @State private var generatedExercises: [Exercise] = []

    
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
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isGenerating)
                }
                
                if generatedSummary != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Use Workout") {
                            workout.name = generatedSummary ?? workout.name
                            workout.exercises = generatedExercises
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("AI Generator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func generateWorkout() async {
        isGenerating = true
        errorMessage = nil
        generatedSummary = nil
        generatedTips = []
        
        do {
            let result = try await aiFunctions.generateWorkout(
                workoutType: userPrompt,
                targetMuscles: nil,
                duration: nil,
                equipment: nil,
                fitnessLevel: nil,
                additionalNotes: nil
            )
            
            // Store in state, don't modify workout yet
            generatedExercises = result.exercises
            generatedSummary = result.summary
            generatedTips = result.tips
            
            // Insert into context
            for exercise in result.exercises {
                context.insert(exercise)
            }
            
            // Only update the workout when user taps "Use Workout"
            print("✅ Workout generated and ready!")
            
        } catch {
            errorMessage = "Failed to generate workout: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isGenerating = false
    }
}

// MARK: - Preview

#Preview {
    CreateWorkoutView()
        .modelContainer(for: [Workout.self, Exercise.self], inMemory: true)
}
