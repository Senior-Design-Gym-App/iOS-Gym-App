//
//  ContentView.swift
//  Rep the Set Watch App
//
//  Created by Troy Madden on 10/7/25.
//

import SwiftUI
internal import Combine

struct Exercise_: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let targetSets: Int
    let targetReps: Int
}

struct Workout_: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let exercises: [Exercise_]
}

extension Workout_ {
    static let demo: [Workout_] = [
        Workout_(name: "Push", exercises: [
            Exercise_(name: "Bench Press", targetSets: 4, targetReps: 8),
            Exercise_(name: "Incline DB Press", targetSets: 3, targetReps: 10),
            Exercise_(name: "Shoulder Press", targetSets: 3, targetReps: 10),
            Exercise_(name: "Triceps Pushdown", targetSets: 3, targetReps: 12)
        ]),
        Workout_(name: "Pull", exercises: [
            Exercise_(name: "Deadlift", targetSets: 3, targetReps: 5),
            Exercise_(name: "Lat Pulldown", targetSets: 3, targetReps: 10),
            Exercise_(name: "Seated Row", targetSets: 3, targetReps: 10),
            Exercise_(name: "Biceps Curl", targetSets: 3, targetReps: 12)
        ]),
        Workout_(name: "Legs", exercises: [
            Exercise_(name: "Squat", targetSets: 5, targetReps: 5),
            Exercise_(name: "Leg Press", targetSets: 3, targetReps: 10),
            Exercise_(name: "Leg Curl", targetSets: 3, targetReps: 12),
            Exercise_(name: "Calf Raise", targetSets: 4, targetReps: 15)
        ])
    ]
}


final class WorkoutSessionModel: ObservableObject {
    @Published var workout: Workout_
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSet: Int = 1
    @Published var currentReps: Int = 0
    @Published var isRunning: Bool = false


    @Published var workoutElapsed: TimeInterval = 0
    @Published var setElapsed: TimeInterval = 0

    private var workoutTimer: Timer?
    private var setTimer: Timer?

    init(workout: Workout_) {
        self.workout = workout
    }

    var currentExercise: Exercise_ { workout.exercises[currentExerciseIndex] }

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

    func nextSet() {
        currentSet += 1
        currentReps = 0
        resetSetTimer()
    }

    func prevSet() {
        currentSet = max(1, currentSet - 1)
        currentReps = 0
        resetSetTimer()
    }

    func incRep() { currentReps += 1 }
    func decRep() { currentReps = max(0, currentReps - 1) }

    func nextExercise() {
        guard currentExerciseIndex + 1 < workout.exercises.count else { return }
        currentExerciseIndex += 1
        currentSet = 1
        currentReps = 0
        resetSetTimer()
    }

    func prevExercise() {
        guard currentExerciseIndex > 0 else { return }
        currentExerciseIndex -= 1
        currentSet = 1
        currentReps = 0
        resetSetTimer()
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

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(Workout_.demo) { workout in
                NavigationLink(workout.name) {
                    WorkoutDetailView(workout: workout)
                }
            }
            .navigationTitle("Workouts")
        }
    }
}

struct WorkoutDetailView: View {
    let workout: Workout_
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

struct WorkoutSessionView: View {
    @StateObject var model: WorkoutSessionModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEndConfirmation = false
    @State private var heartRate: Int = 0
    @State private var hrTimer: Timer?
    
    @State private var currentTimeString: String = Date.now.formatted(date: .omitted, time: .standard)
    
    var body: some View {
        ScrollView {
            VStack() {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    Text("\(heartRate) BPM")
                        .monospacedDigit()
                        .font(.caption)
                }
                
                VStack(spacing: 6) {
                    LabeledContent("Workout") {
                        Text(timeString(model.workoutElapsed))
                            .monospacedDigit()
                    }
                    
                    VStack(spacing: 2) {
                        Text(model.currentExercise.name)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text("Set \(model.currentSet) of \(model.currentExercise.targetSets) • Target: \(model.currentExercise.targetReps) reps")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                    
                    LabeledContent("Set") {
                        Text(timeString(model.setElapsed))
                            .monospacedDigit()
                    }
                    
                    HStack(spacing: 10) {
                        Button("Prev Set") { model.prevSet() }
                        Button("Next Set") { model.nextSet() }
                    }
                    .font(.caption)
                    
                    HStack(spacing: 10) {
                        Button("Prev Ex.") { model.prevExercise() }
                        Button("Next Ex.") { model.nextExercise() }
                    }
                    .font(.caption)
                    
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
                Button("End Workout", role: .destructive) {
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to end this workout?")
            }
        }
        .navigationTitle("Session")
        .onAppear {
            model.start()
            //dummy heart rate updates (replace with HealthKit later)
            hrTimer?.invalidate()
            hrTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                heartRate = Int.random(in: 110...150)
            }
        }
        .onDisappear {
            model.pause()
            hrTimer?.invalidate(); hrTimer = nil
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

