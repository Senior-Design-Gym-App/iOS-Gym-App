//
//  WatchSessionManager+Bindings.swift
//  watchOS Gym App
//
//  Helper extensions for creating SwiftUI bindings that automatically sync
//

import SwiftUI

extension WatchSessionManager {
    
    /// Create a binding for reps that automatically syncs changes
    func repsBinding() -> Binding<Int> {
        Binding(
            get: { self.currentReps },
            set: { newValue in
                self.updateReps(newValue)
            }
        )
    }
    
    /// Create a binding for weight that automatically syncs changes
    func weightBinding() -> Binding<Double> {
        Binding(
            get: { self.currentWeight },
            set: { newValue in
                self.updateWeight(newValue)
            }
        )
    }
    
    /// Create a binding for rest time that automatically syncs changes
    func restBinding() -> Binding<Int> {
        Binding(
            get: { self.restTime },
            set: { newValue in
                guard newValue != self.restTime, !self.isReceivingUpdate else { return }
                self.restTime = newValue
                self.sendAction(.updateRest)
            }
        )
    }
    
    /// Create a binding for rest time as Double (useful for Sliders)
    func restBindingDouble() -> Binding<Double> {
        Binding(
            get: { Double(self.restTime) },
            set: { newValue in
                let intValue = Int(newValue)
                guard intValue != self.restTime, !self.isReceivingUpdate else { return }
                self.restTime = intValue
                self.sendAction(.updateRest)
            }
        )
    }
}

// MARK: - Usage Examples

/*
 
 Now in your Watch views, you can use these bindings directly:
 
 struct WatchWorkoutControlsView: View {
     @Environment(WatchSessionManager.self) private var sessionManager
     
     var body: some View {
         VStack {
             // Reps stepper - automatically syncs!
             Stepper("Reps: \(sessionManager.currentReps)", 
                     value: sessionManager.repsBinding(), 
                     in: 1...100)
             
             // Weight picker - automatically syncs!
             Picker("Weight", selection: sessionManager.weightBinding()) {
                 ForEach([45, 50, 55, 60, 65, 70, 75, 80, 85, 90], id: \.self) { weight in
                     Text("\(weight, specifier: "%.0f") lbs").tag(Double(weight))
                 }
             }
             
             // Rest time slider - automatically syncs!
             Slider(value: sessionManager.restBindingDouble(), in: 30...300, step: 15)
             Text("\(sessionManager.restTime) seconds")
             
             // Buttons work the same
             HStack {
                 Button("Previous Set") {
                     sessionManager.previousSet()
                 }
                 Button("Next Set") {
                     sessionManager.nextSet()
                 }
             }
         }
     }
 }
 
 This is much simpler than managing local @State variables!
 The bindings automatically:
 - Read from WatchSessionManager
 - Call the sync methods when values change
 - Work with Steppers, Pickers, Sliders, TextFields, etc.
 - Prevent feedback loops with isReceivingUpdate guard
 
 IMPORTANT: These are functions that return bindings, not computed properties!
 Use sessionManager.repsBinding() with parentheses, not sessionManager.repsBinding
 
 */
