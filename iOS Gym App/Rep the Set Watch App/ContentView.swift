//
//  ContentView.swift
//  Rep the Set Watch App
//
//  Main workout view using synced data from iPhone
//

import SwiftUI
internal import Combine
import WatchConnectivity
import HealthKit

// MARK: - Workout Session Model

final class WorkoutSessionModel: ObservableObject {
    @Published var workout: WorkoutTransfer
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSet: Int = 1
    @Published var completedSets: [[Int]] = [] // [exercise][set] = reps
    @Published var weights: [[Double]] = [] // [exercise][set] = weight
    @Published var isRunning: Bool = false

    @Published var workoutElapsed: TimeInterval = 0
    @Published var setElapsed: TimeInterval = 0

    private var workoutTimer: Timer?
    private var setTimer: Timer?

    init(workout: WorkoutTransfer) {
        self.workout = workout
        // Initialize tracking arrays
        self.completedSets = Array(repeating: [], count: workout.exercises.count)
        self.weights = Array(repeating: [], count: workout.exercises.count)
    }

    var currentExercise: ExerciseTransfer {
        workout.exercises[currentExerciseIndex]
    }
    
    var currentReps: Int {
        let exerciseSets = completedSets[currentExerciseIndex]
        return currentSet <= exerciseSets.count ? exerciseSets[currentSet - 1] : 0
    }
    
    var currentWeight: Double {
        let exerciseWeights = weights[currentExerciseIndex]
        return currentSet <= exerciseWeights.count ? exerciseWeights[currentSet - 1] : currentExercise.targetWeight ?? 0
    }

    func start() {
        isRunning = true
        startWorkoutTimer()
        startSetTimer()
    }

    func pause() {
        isRunning = false
        workoutTimer?.invalidate()
        setTimer?.invalidate()
    }

    func resetSetTimer() {
        setElapsed = 0
        setTimer?.invalidate()
        if isRunning { startSetTimer() }
    }
    
    func logSet(reps: Int, weight: Double) {
        // Ensure arrays are large enough
        while completedSets[currentExerciseIndex].count < currentSet {
            completedSets[currentExerciseIndex].append(0)
            weights[currentExerciseIndex].append(currentExercise.targetWeight ?? 0)
        }
        
        // Update or append
        if currentSet <= completedSets[currentExerciseIndex].count {
            completedSets[currentExerciseIndex][currentSet - 1] = reps
            weights[currentExerciseIndex][currentSet - 1] = weight
        } else {
            completedSets[currentExerciseIndex].append(reps)
            weights[currentExerciseIndex].append(weight)
        }
    }

    func nextSet() {
        currentSet += 1
        resetSetTimer()
    }

    func prevSet() {
        currentSet = max(1, currentSet - 1)
        resetSetTimer()
    }

    func nextExercise() {
        guard currentExerciseIndex + 1 < workout.exercises.count else { return }
        currentExerciseIndex += 1
        currentSet = 1
        resetSetTimer()
    }

    func prevExercise() {
        guard currentExerciseIndex > 0 else { return }
        currentExerciseIndex -= 1
        currentSet = 1
        resetSetTimer()
    }
    
    func completeWorkout() -> WorkoutSessionTransfer {
        // Convert to transfer model for sending back to iPhone
        var entries: [SessionEntryTransfer] = []
        
        for (index, exercise) in workout.exercises.enumerated() {
            let reps = completedSets[index]
            let weight = weights[index]
            
            entries.append(SessionEntryTransfer(
                exerciseId: exercise.id,
                reps: reps,
                weight: weight
            ))
        }
        
        return WorkoutSessionTransfer(
            name: workout.name,
            started: Date(timeIntervalSinceNow: -workoutElapsed),
            completed: Date(),
            workoutId: workout.id,
            entries: entries
        )
    }

    private func startWorkoutTimer() {
        workoutTimer?.invalidate()
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.workoutElapsed += 1
        }
    }

    private func startSetTimer() {
        setTimer?.invalidate()
        setTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.setElapsed += 1
        }
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @State private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        NavigationStack {
            if connectivityManager.workouts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("No Workouts")
                        .font(.headline)
                    
                    Text("Open the iPhone app to sync your workouts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if let lastSync = connectivityManager.lastSyncDate {
                        Text("Last sync: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                    }
                    
                    VStack(spacing: 8) {
                        Button {
                            checkApplicationContext()
                        } label: {
                            Label("Check App Context", systemImage: "tray.and.arrow.down")
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            connectivityManager.requestWorkouts()
                        } label: {
                            Label("Request from iPhone", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top)
                }
                .padding()
            } else {
                List {
                    if let split = connectivityManager.activeSplit {
                        Section("Active Split: \(split.name)") {
                            ForEach(split.workouts) { workout in
                                WorkoutRow(workout: workout)
                            }
                        }
                    }
                    
                    Section("All Workouts") {
                        ForEach(connectivityManager.workouts) { workout in
                            WorkoutRow(workout: workout)
                        }
                    }
                }
                .navigationTitle("Workouts")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink {
                            DebugConnectivityView()
                        } label: {
                            Image(systemName: "ant.fill")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            connectivityManager.requestWorkouts()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
    }
    
    private func checkApplicationContext() {
        let session = WCSession.default
        let context = session.receivedApplicationContext
        
        print("⌚️ Checking received application context...")
        print("⌚️ Context keys: \(context.keys)")
        
        if let workoutsData = context["workouts"] as? Data {
            print("✅ Found workouts data: \(workoutsData.count) bytes")
            do {
                let workouts = try JSONDecoder().decode([WorkoutTransfer].self, from: workoutsData)
                print("✅ Successfully decoded \(workouts.count) workouts from context")
                
                // Manually update if not already loaded
                if connectivityManager.workouts.isEmpty {
                    connectivityManager.workouts = workouts
                    print("✅ Manually loaded workouts into app")
                }
            } catch {
                print("❌ Failed to decode: \(error)")
            }
        } else {
            print("⚠️ No workouts data in received context")
            print("⚠️ iPhone may not have sent data yet. Open iPhone app and wait 30 seconds.")
        }
    }
}

// MARK: - Workout Row

struct WorkoutRow: View {
    let workout: WorkoutTransfer
    
    var body: some View {
        NavigationLink {
            WorkoutDetailView(workout: workout)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                
                Text("\(workout.exercises.count) exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Workout Detail View

struct WorkoutDetailView: View {
    let workout: WorkoutTransfer
    @State private var start = false
    @State private var showInfo = false

    var body: some View {
        VStack(spacing: 8) {
            Text(workout.name)
                .font(.headline)

            Text("Exercises: \(workout.exercises.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Start Workout") {
                start = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
            .fullScreenCover(isPresented: $start) {
                WorkoutSessionView(model: WorkoutSessionModel(workout: workout))
            }
            
            Button("About This Plan") {
                showInfo = true
            }
            .buttonStyle(.bordered)

            .sheet(isPresented: $showInfo) {
                VStack(spacing: 8) {
                    Text(workout.name)
                        .font(.headline)
                    Text("Exercises: \(workout.exercises.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Divider()
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(workout.exercises) { ex in
                            HStack {
                                Text(ex.name)
                                    .lineLimit(2)
                                Spacer()
                                Text("\(ex.targetSets)x\(ex.targetReps)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .navigationTitle("About Plan")
            }
        }
        .navigationTitle(workout.name)
    }
}

// MARK: - Workout Session View

struct WorkoutSessionView: View {
    @StateObject var model: WorkoutSessionModel
    @State private var heartRateManager = HeartRateManager()
    @Environment(\.dismiss) private var dismiss
    @State private var showEndConfirmation = false
    @State private var repsInput: Int = 0
    @State private var weightInput: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Heart rate
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(heartRateManager.currentHeartRate > 0 ? .red : .gray)
                        Text("\(heartRateManager.currentHeartRate) BPM")
                            .monospacedDigit()
                            .font(.caption)
                        
                        if !heartRateManager.isAuthorized {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    // Debug info
                    if !heartRateManager.isAuthorized {
                        VStack(spacing: 2) {
                            Text("HealthKit not authorized")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Button("Request Access") {
                                Task {
                                    await heartRateManager.requestAuthorization()
                                }
                            }
                            .font(.caption2)
                            .buttonStyle(.bordered)
                        }
                    } else if heartRateManager.currentHeartRate == 0 {
                        Text("Waiting for heart rate...")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(spacing: 8) {
                    // Timers
                    LabeledContent("Workout") {
                        Text(timeString(model.workoutElapsed))
                            .monospacedDigit()
                    }
                    
                    // Exercise info
                    VStack(spacing: 2) {
                        Text(model.currentExercise.name)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text("Set \(model.currentSet) of \(model.currentExercise.targetSets) • Target: \(model.currentExercise.targetReps) reps")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    LabeledContent("Set") {
                        Text(timeString(model.setElapsed))
                            .monospacedDigit()
                    }
                    
                    // Reps & Weight input
                    VStack(spacing: 6) {
                        HStack {
                            Text("Reps:")
                            Spacer()
                            Button("-") { repsInput = max(0, repsInput - 1) }
                            Text("\(repsInput)")
                                .frame(width: 40)
                                .monospacedDigit()
                            Button("+") { repsInput += 1 }
                        }
                        .font(.caption)
                        
                        HStack {
                            Text("Weight:")
                            Spacer()
                            Button("-") { weightInput = max(0, weightInput - 5) }
                            Text(String(format: "%.0f", weightInput))
                                .frame(width: 40)
                                .monospacedDigit()
                            Button("+") { weightInput += 5 }
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 4)
                    
                    // Log set button
                    Button("Log Set") {
                        model.logSet(reps: repsInput, weight: weightInput)
                        model.nextSet()
                        repsInput = model.currentExercise.targetReps
                        weightInput = model.currentExercise.targetWeight ?? weightInput
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(repsInput == 0)
                    
                    // Navigation
                    HStack(spacing: 10) {
                        Button("Prev Set") {
                            model.prevSet()
                            repsInput = model.currentReps
                            weightInput = model.currentWeight
                        }
                        Button("Next Set") { model.nextSet() }
                            .handGestureShortcut(.primaryAction)
                    }
                    .font(.caption)
                    
                    HStack(spacing: 10) {
                        Button("Prev Ex.") {
                            model.prevExercise()
                            repsInput = model.currentExercise.targetReps
                            weightInput = model.currentExercise.targetWeight ?? 0
                        }
                        Button("Next Ex.") {
                            model.nextExercise()
                            repsInput = model.currentExercise.targetReps
                            weightInput = model.currentExercise.targetWeight ?? 0
                        }
                    }
                    .font(.caption)
                    
                    // Controls
                    HStack(spacing: 10) {
                        Button(model.isRunning ? "Pause" : "Start") {
                            model.isRunning ? model.pause() : model.start()
                        }
                        Button("Reset Set") { model.resetSetTimer() }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 4)
                }
                .padding(.horizontal)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width > 40 && abs(value.translation.height) < 30 {
                            showEndConfirmation = true
                        }
                    }
            )
            .confirmationDialog("End Workout?", isPresented: $showEndConfirmation, titleVisibility: .visible) {
                Button("Complete Workout", role: .destructive) {
                    let session = model.completeWorkout()
                    WatchConnectivityManager.shared.sendCompletedSession(session)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will save your workout to your iPhone")
            }
        }
        .navigationTitle("Session")
        .onAppear {
            model.start()
            repsInput = model.currentExercise.targetReps
            weightInput = model.currentExercise.targetWeight ?? 0
            
            // Start HealthKit workout session
            Task {
                do {
                    try await heartRateManager.startWorkoutSession()
                } catch {
                    print("❌ Failed to start workout session: \(error.localizedDescription)")
                }
            }
        }
        .onDisappear {
            model.pause()
            
            // End HealthKit workout session
            Task {
                do {
                    try await heartRateManager.endWorkoutSession()
                } catch {
                    print("❌ Failed to end workout session: \(error.localizedDescription)")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func timeString(_ interval: TimeInterval) -> String {
        let seconds = Int(interval) % 60
        let minutes = (Int(interval) / 60) % 60
        let hours = Int(interval) / 3600
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    ContentView()
}
