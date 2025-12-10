//
//  SessionManager+Bindings.swift
//  iOS Gym App
//
//  Helper extensions for creating SwiftUI bindings that automatically sync
//
//  These bindings work seamlessly with Watch sync:
//  - Changes made via bindings automatically sync to Watch
//  - The isReceivingUpdate flag prevents feedback loops
//  - State syncs happen after a small delay to ensure message ordering
//

import SwiftUI

extension SessionManager {
    
    /// Create a binding for reps that automatically syncs changes
    func repsBinding() -> Binding<Int> {
        Binding(
            get: { self.reps },
            set: { newValue in
                self.updateReps(newValue)
            }
        )
    }
    
    /// Create a binding for weight that automatically syncs changes
    func weightBinding() -> Binding<Double> {
        Binding(
            get: { self.weight },
            set: { newValue in
                self.updateWeight(newValue)
            }
        )
    }
    
    /// Create a binding for rest time that automatically syncs changes
    func restBinding() -> Binding<Int> {
        Binding(
            get: { self.rest },
            set: { newValue in
                self.updateRest(newValue)
            }
        )
    }
    
    /// Create a binding for rest time as Double (useful for Sliders)
    func restBindingDouble() -> Binding<Double> {
        Binding(
            get: { Double(self.rest) },
            set: { newValue in
                self.updateRest(Int(newValue))
            }
        )
    }
}

// MARK: - Usage Examples

/*
 
 Now in your views, you can use these bindings directly:
 
 struct WorkoutControlsView: View {
     @Environment(SessionManager.self) private var sm
     
     var body: some View {
         Form {
             // Reps stepper - automatically syncs!
             Stepper("Reps: \(sm.reps)", value: sm.repsBinding(), in: 1...100)
             
             // Weight text field - automatically syncs!
             HStack {
                 Text("Weight")
                 TextField("Weight", value: sm.weightBinding(), format: .number)
                     .textFieldStyle(.roundedBorder)
                     .keyboardType(.decimalPad)
             }
             
             // Rest slider - automatically syncs!
             VStack(alignment: .leading) {
                 Text("Rest: \(sm.rest) seconds")
                 Slider(value: sm.restBindingDouble(), in: 0...300, step: 15)
             }
             
             // Buttons still work the same
             HStack {
                 Button("Previous Set") {
                     sm.PreviousSet()
                 }
                 Button("Next Set") {
                     sm.NextSet()
                 }
             }
         }
     }
 }
 
 This is much simpler than managing local @State variables!
 The bindings automatically:
 - Read from SessionManager
 - Call the sync methods when values change
 - Work with Steppers, TextFields, Sliders, etc.
 
 IMPORTANT: These are functions that return bindings, not computed properties!
 Use sm.repsBinding() with parentheses, not sm.repsBinding
 
 */
