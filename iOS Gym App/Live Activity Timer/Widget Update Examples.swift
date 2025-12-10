//
//  Widget Update Examples.swift
//  Quick reference for updating widgets throughout your app
//
//  ⚠️ This file is for reference only - copy the relevant code to where you need it
//

import Foundation
import WidgetKit

// MARK: - Common Widget Update Scenarios

/// Example 1: After editing a workout's details (name, exercises, etc.)
func exampleEditWorkout() {
    // Your workout editing code here...
    // workout.name = newName
    // workout.exercises = newExercises
    
    // Check if this workout belongs to the active split
    // Note: You'll need to adapt this to your actual data model
    /*
    if let split = workout.split, split.active {
        let transferSplit = split.toTransfer()
        WidgetDataManager.shared.refreshActiveSplit(transferSplit)
    }
    */
}

/// Example 2: After completing a workout session
func exampleCompleteWorkout(workoutId: UUID) {
    // Mark workout as completed and advance split progress
    WidgetDataManager.shared.markWorkoutCompleted(workoutId: workoutId)
    
    // This automatically:
    // - Updates lastCompletedWorkoutIndex
    // - Reloads all widgets
    // - Shows the next workout in the split
}

/// Example 3: When user wants to restart their split from the beginning
func exampleResetSplitProgress() {
    WidgetDataManager.shared.resetSplitProgress()
    
    // This resets the split to workout #1
}

/// Example 4: Manually reload widgets (if needed)
func exampleManualReload() {
    // Sometimes you just want to force a refresh
    WidgetDataManager.shared.reloadWidgets()
}

/// Example 5: Activate a different split programmatically
func exampleActivateSplit(split: SplitTransfer) {
    // First deactivate any existing splits
    // (you'd need to do this in your data layer)
    
    // Then activate the new one
    WidgetDataManager.shared.setActiveSplit(split)
    WidgetDataManager.shared.resetSplitProgress()
}

/// Example 6: Deactivate all splits (clear widget)
func exampleDeactivateAllSplits() {
    WidgetDataManager.shared.setActiveSplit(nil)
}

/// Example 7: Check what's currently in the widget
func exampleCheckWidgetState() {
    if let activeSplit = WidgetDataManager.shared.getActiveSplit() {
        print("Widget is showing: \(activeSplit.name)")
        print("Number of workouts: \(activeSplit.workouts.count)")
        
        if let nextWorkout = WidgetDataManager.shared.getNextWorkoutInSplit() {
            print("Next workout: \(nextWorkout.name)")
        }
    } else {
        print("Widget is empty (no active split)")
    }
}

/// Example 8: Debug widget state (DEBUG builds only)
#if DEBUG
func exampleDebugWidget() {
    // This prints detailed information about widget state
    WidgetDataManager.shared.debugPrintState()
    
    // Output example:
    // 🔍 Widget Debug State:
    //    Active Split: Push/Pull/Legs
    //    Workouts: 3
    //      1. Push Day (6 exercises)
    //      2. Pull Day (5 exercises)
    //      3. Leg Day (7 exercises)
    //    Next Workout: Pull Day (index 1)
}
#endif

// MARK: - Integration Points in Your App

/*
 
 ✅ Already Integrated (No Action Needed):
 
 1. Activating/Deactivating Splits
    - Location: Reused Split Views.swift > ActiveSplit button
    - Automatically updates widget ✓
 
 2. Adding/Removing/Reordering Workouts in Split
    - Location: Reused Split Views.swift > SplitControls.SaveOptions()
    - Automatically updates widget ✓
 
 3. Deleting Active Split
    - Location: Edit Split.swift > Delete()
    - Automatically clears widget ✓
 
 4. Completing a Workout
    - Call: WidgetDataManager.shared.markWorkoutCompleted(workoutId:)
    - Updates progress and reloads widget ✓
 
 
 🔧 May Need Integration:
 
 1. Editing Individual Workout Details
    - If you have a workout editing view
    - Add: Check if workout.split.active, then call refreshActiveSplit()
 
 2. Bulk Operations
    - If you import/export splits
    - If you have "duplicate split" feature
    - Add: Call setActiveSplit() after operation
 
 3. Settings/Preferences
    - If you have a "reset all data" feature
    - Add: Call setActiveSplit(nil) to clear widget
 
 */

// MARK: - Testing Checklist

/*
 
 Test these scenarios to ensure widgets update correctly:
 
 ☐ Activate a split → Widget shows split workouts
 ☐ Deactivate a split → Widget shows "No Active Split"
 ☐ Complete a workout → Widget advances to next workout
 ☐ Add workout to active split → Widget updates with new workout
 ☐ Remove workout from active split → Widget updates without removed workout
 ☐ Reorder workouts in active split → Widget reflects new order
 ☐ Rename active split → Widget shows new name
 ☐ Edit workout name in active split → Widget shows updated name
 ☐ Delete active split → Widget clears
 ☐ Reset split progress → Widget shows first workout again
 
 */
