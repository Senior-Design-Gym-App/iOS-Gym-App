//
//  AIAskView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI
import SwiftData

struct AIMessage: Identifiable {
    var id = UUID()
    var text: String
    var isUser: Bool
    var actionType: ActionType? = nil
    var actionData: [String: Any]? = nil
    
    enum ActionType {
        case createWorkout
        case createExercise
        case viewWorkouts
    }
}

struct AIAskView: View {
    @State private var prompt: String = ""
    @State private var messages: [AIMessage] = [
        AIMessage(text: "Ask me anything about training, programming, or nutrition.", isUser: false)
    ]
    @State private var isLoading: Bool = false
    @State private var showCreateWorkout = false
    @State private var generatedWorkoutData: (name: String, exercises: [Exercise], summary: String, tips: [String])?
    
    @Environment(\.modelContext) private var modelContext
    
    private let suggestions: [String] = [
        "Build me a 4-day push/pull split",
        "How to improve bench press?",
        "Recommend a mobility routine",
        "What should I do for fat loss?"
    ]
    
    private let chipCornerRadius = Constants.cornerRadius
    private let chipSpacing: CGFloat = Constants.customLabelPadding
    private let inputRadius: CGFloat = Constants.cornerRadius + 8
    private let primaryTint = Constants.mainAppTheme
    private let bubbleCornerRadius = Constants.cornerRadius + 4
    
    // Remove @State - just create the instance directly
    private let ai = AIFunctions()
    
    var body: some View {
        VStack(spacing: 0) {
            // Suggestions chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: chipSpacing) {
                    ForEach(suggestions, id: \.self) { item in
                        Button(action: {
                            prompt = item
                            sendMessage()
                        }) {
                            HStack(spacing: chipSpacing) {
                                Image(systemName: "sparkles")
                                    .font(.footnote)
                                Text(item)
                                    .font(.footnote)
                            }
                            .padding(.vertical, chipSpacing + 3)
                            .padding(.horizontal, Constants.titlePadding * 2)
                            .background(
                                RoundedRectangle(cornerRadius: chipCornerRadius, style: .continuous)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: chipCornerRadius, style: .continuous)
                                    .stroke(Color(.separator))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }

            Divider()

            // Messages area
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(messages) { message in
                            VStack(spacing: 8) {
                                ChatBubble(text: message.text, isUser: message.isUser)
                                    .id(message.id)
                                
                                // Action buttons for AI messages
                                if !message.isUser, let actionType = message.actionType {
                                    ActionButtonView(actionType: actionType, action: {
                                        handleAction(actionType: actionType, data: message.actionData)
                                    })
                                }
                            }
                        }
                        
                        // Loading indicator
                        if isLoading {
                            AILoadingIndicator()
                                .id("loading")
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                }
                .onChange(of: messages.count) { _, _ in
                    // Auto-scroll to newest message
                    if let lastMessage = messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { _, newValue in
                    if newValue {
                        // Scroll to loading indicator
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo("loading", anchor: .bottom)
                            }
                        }
                    }
                }
            }

            // Input bar
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(primaryTint.opacity(0.6))
                    TextField("Ask anything…", text: $prompt, axis: .vertical)
                        .textInputAutocapitalization(.sentences)
                        .font(.body)
                        .onSubmit {
                            sendMessage()
                        }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: inputRadius, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: inputRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [primaryTint.opacity(0.3), primaryTint.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [primaryTint, primaryTint.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: primaryTint.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                }
                .buttonStyle(.plain)
                .disabled(prompt.isEmpty || isLoading)
                .opacity(prompt.isEmpty || isLoading ? 0.5 : 1.0)
                .scaleEffect(prompt.isEmpty || isLoading ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: prompt.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
        }
        .navigationTitle("Ask AI")
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreateWorkout) {
            if let workoutData = generatedWorkoutData {
                CreateWorkoutFromAIView(
                    workoutName: workoutData.name,
                    exercises: workoutData.exercises,
                    summary: workoutData.summary,
                    tips: workoutData.tips,
                    modelContext: modelContext
                )
            }
        }
        .onChange(of: showCreateWorkout) { _, isShowing in
            // Reset generated data when sheet is dismissed
            if !isShowing {
                generatedWorkoutData = nil
            }
        }
    }
    
    private func sendMessage() {
        let userMessage = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // Add user message
        messages.append(AIMessage(text: userMessage, isUser: true))
        prompt = ""
        isLoading = true
        
        // Check if user wants to create a workout
        let lowercasedMessage = userMessage.lowercased()
        let workoutKeywords = ["workout", "split", "routine", "program", "training plan", "exercise plan"]
        let wantsWorkout = workoutKeywords.contains { lowercasedMessage.contains($0) }
        
        // Call AI function
        Task {
            do {
                if wantsWorkout {
                    // Generate workout directly
                    let workoutData = try await ai.generateWorkout(
                        workoutType: userMessage,
                        targetMuscles: nil,
                        duration: nil,
                        equipment: nil,
                        fitnessLevel: nil,
                        additionalNotes: nil
                    )
                    
                    await MainActor.run {
                        let summaryText = "\(workoutData.summary)\n\nTips:\n" + workoutData.tips.map { "• \($0)" }.joined(separator: "\n")
                        messages.append(AIMessage(
                            text: summaryText,
                            isUser: false,
                            actionType: .createWorkout,
                            actionData: ["workoutName": workoutData.name]
                        ))
                        generatedWorkoutData = workoutData
                        isLoading = false
                    }
                } else {
                    // Regular text response
                    let response = try await ai.genericResponse(message: userMessage)
                    print("AI Response: \(response)")
                    
                    // Check if response suggests creating a workout
                    let responseLower = response.lowercased()
                    let suggestsWorkout = workoutKeywords.contains { responseLower.contains($0) } &&
                                         (responseLower.contains("create") || responseLower.contains("build") || responseLower.contains("generate"))
                    
                    await MainActor.run {
                        messages.append(AIMessage(
                            text: response,
                            isUser: false,
                            actionType: suggestsWorkout ? .createWorkout : nil
                        ))
                        isLoading = false
                    }
                }
            } catch {
                // Handle error
                await MainActor.run {
                    messages.append(AIMessage(text: "Sorry, I encountered an error. Please try again.", isUser: false))
                    isLoading = false
                }
                print("AI Error: \(error)")
            }
        }
    }
    
    private func handleAction(actionType: AIMessage.ActionType, data: [String: Any]?) {
        switch actionType {
        case .createWorkout:
            // If we have generated workout data, show the sheet
            if generatedWorkoutData != nil {
                showCreateWorkout = true
            } else {
                // Navigate to create workout view
                // This would require navigation, but for now we'll show a sheet
                showCreateWorkout = true
            }
        case .createExercise:
            // Handle create exercise
            break
        case .viewWorkouts:
            // Handle view workouts
            break
        }
    }
}

private struct ChatBubble: View {
    let text: String
    let isUser: Bool
    
    private let cornerRadius: CGFloat = 20
    private let userTint = Constants.mainAppTheme
    private let bubblePadding: CGFloat = 14
    
    var body: some View {
        if isUser {
            // User message - aligned to right
            HStack(alignment: .top, spacing: 8) {
                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(text)
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(.vertical, bubblePadding)
                        .padding(.horizontal, bubblePadding + 2)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [userTint, userTint.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: userTint.opacity(0.3), radius: 8, x: 0, y: 4)
                        .frame(maxWidth: 280, alignment: .trailing)
                }
                
                // User Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [userTint.opacity(0.4), userTint.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 4)
        } else {
            // AI message - aligned to left
            HStack(alignment: .top, spacing: 8) {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [userTint.opacity(0.3), userTint.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(userTint)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .padding(.vertical, bubblePadding)
                        .padding(.horizontal, bubblePadding + 2)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [userTint.opacity(0.2), userTint.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .frame(maxWidth: 280, alignment: .leading)
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 4)
        }
    }
}

private struct AILoadingIndicator: View {
    @State private var isAnimating = false
    private let dotSize: CGFloat = 8
    private let dotSpacing: CGFloat = 6
    private let primaryTint = Constants.mainAppTheme
    private let bubbleCornerRadius: CGFloat = 20
    private let bubblePadding: CGFloat = 14
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [primaryTint.opacity(0.3), primaryTint.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(primaryTint)
            }
            
            HStack(spacing: dotSpacing) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [primaryTint, primaryTint.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: dotSize, height: dotSize)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            .padding(.vertical, bubblePadding)
            .padding(.horizontal, bubblePadding + 2)
            .background(
                RoundedRectangle(cornerRadius: bubbleCornerRadius, style: .continuous)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: bubbleCornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [primaryTint.opacity(0.2), primaryTint.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .frame(maxWidth: 280, alignment: .leading)
            
            Spacer(minLength: 50)
        }
        .padding(.horizontal, 4)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Action Button View
private struct ActionButtonView: View {
    let actionType: AIMessage.ActionType
    let action: () -> Void
    
    private let primaryTint = Constants.mainAppTheme
    
    var body: some View {
        HStack {
            Spacer(minLength: 50)
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 14, weight: .semibold))
                    Text(buttonText)
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        colors: [primaryTint, primaryTint.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: primaryTint.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            Spacer(minLength: 50)
        }
        .padding(.top, 4)
    }
    
    private var iconName: String {
        switch actionType {
        case .createWorkout:
            return "plus.circle.fill"
        case .createExercise:
            return "figure.strengthtraining.traditional"
        case .viewWorkouts:
            return "list.bullet"
        }
    }
    
    private var buttonText: String {
        switch actionType {
        case .createWorkout:
            return "Create Workout"
        case .createExercise:
            return "Create Exercise"
        case .viewWorkouts:
            return "View Workouts"
        }
    }
}

// MARK: - Create Workout From AI View
struct CreateWorkoutFromAIView: View {
    let workoutName: String
    let exercises: [Exercise]
    let summary: String
    let tips: [String]
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    @State private var newWorkout: Workout
    @State private var showSuccessAlert = false
    @State private var savedWorkout: Workout?
    
    init(workoutName: String, exercises: [Exercise], summary: String, tips: [String], modelContext: ModelContext) {
        self.workoutName = workoutName
        self.exercises = exercises
        self.summary = summary
        self.tips = tips
        self.modelContext = modelContext
        _newWorkout = State(initialValue: Workout(name: workoutName, exercises: []))
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Summary section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(summary)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        
                        if !tips.isEmpty {
                            Divider()
                            Text("Tips:")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            ForEach(tips, id: \.self) { tip in
                                Text("• \(tip)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Workout Summary")
                }
                
                // Exercises section
                Section {
                    ForEach(exercises, id: \.id) { exercise in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.headline)
                            if let muscle = exercise.muscleWorked {
                                Text(muscle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if let sets = exercise.reps.first?.count {
                                Text("\(sets) sets")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Exercises (\(exercises.count))")
                }
            }
            .navigationTitle(workoutName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                }
            }
            .alert("Workout Saved!", isPresented: $showSuccessAlert) {
                Button("View Workouts") {
                    dismiss()
                    // Navigate to workouts - this will be handled by the parent
                }
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("'\(workoutName)' has been saved to your workouts. You can find it in the Workouts tab.")
            }
        }
    }
    
    private func saveWorkout() {
        // Insert exercises into context first
        for exercise in exercises {
            modelContext.insert(exercise)
        }
        
        // Update workout
        newWorkout.name = workoutName
        newWorkout.exercises = exercises
        newWorkout.modified = Date()
        newWorkout.created = Date()
        
        // Insert workout into context
        modelContext.insert(newWorkout)
        
        // Save context to get persistent identifiers
        do {
            try modelContext.save()
            
            // Now encode the order after saving (so we have persistent IDs)
            if let savedExercises = newWorkout.exercises {
                let newIDs = savedExercises.map { $0.persistentModelID }
                newWorkout.encodeIDs(ids: newIDs)
                try modelContext.save() // Save again with encoded order
            }
            
            savedWorkout = newWorkout
            print("✅ Saved workout: \(workoutName) with \(exercises.count) exercises")
            showSuccessAlert = true
        } catch {
            print("❌ Failed to save workout: \(error)")
            // Show error alert
        }
    }
}

#Preview {
    NavigationStack {
        AIAskView()
    }
}
