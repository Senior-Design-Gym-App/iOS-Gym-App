# Heart Rate Auto-Advance Feature

## Overview

The heart rate auto-advance feature uses Apple Watch's heart rate sensor to automatically advance to the next set when it detects that the user has finished exercising and is recovering.

## How It Works

### Detection Algorithm

1. **Set Start Detection**: When heart rate increases by at least 5 BPM over a 3-second rolling average, the system recognizes the user has started a set.

2. **Peak Tracking**: During the set, the system tracks the peak heart rate achieved.

3. **Recovery Detection**: When heart rate drops to 85% or below of the peak heart rate, the system recognizes recovery and automatically advances to the next set.

### Implementation Details

- Uses `HKWorkoutSession` to access live heart rate data
- Samples heart rate approximately once per second
- Maintains a rolling window of the last 10 heart rate readings
- Requires at least 5 readings before detecting patterns

### Usage

```swift
// In your Watch app, create the session manager
let sessionManager = WatchSessionManager()

// Enable auto-advance
sessionManager.isAutoAdvanceEnabled = true

// Start a workout session
// Heart rate monitoring will begin automatically if auto-advance is enabled
```

### UI Integration

The heart rate auto-advance toggle has been integrated into the `ActiveSessionView` which displays when a workout is started from the iPhone and synced to the Watch.

**Location in the app:**
1. Start a workout from your iPhone
2. Open the Watch app - the workout will automatically open
3. At the top of the `ActiveSessionView`, you'll see the "Auto-Advance" toggle with a heart icon
4. Toggle it on to enable automatic set advancement based on heart rate

**Custom Integration:**

If you want to add the toggle to other views, use the `HeartRateAutoAdvanceToggle` component:

```swift
import SwiftUI

struct WorkoutView: View {
    @Bindable var sessionManager: WatchSessionManager
    
    var body: some View {
        VStack {
            // Your workout UI
            
            HeartRateAutoAdvanceToggle(sessionManager: sessionManager)
        }
    }
}
```

**Already Integrated In:**
- `ActiveSessionView` (ContentView.swift) - Shows when workout is synced from iPhone

## Privacy & Permissions

The feature requires HealthKit authorization:
- **Read**: Heart Rate (`HKQuantityType.heartRate`)
- **Write**: Workouts (`HKObjectType.workoutType()`)

Authorization is requested automatically when `WatchSessionManager` is initialized.

## Customization

You can customize the detection thresholds by modifying these properties:

- `heartRateThreshold`: Default is 0.85 (85% of peak). Lower values make it more sensitive.
- Heart rate increase threshold: Currently 5 BPM increase to detect set start.
- History window: Currently tracks last 10 readings (~10 seconds).

Example:
```swift
// In WatchSessionManager.swift, modify:
@ObservationIgnored private let heartRateThreshold: Double = 0.80 // More sensitive (80%)
```

## Limitations

- Requires Apple Watch Series 1 or later
- Works best for exercises with clear exertion/recovery patterns
- May not work well for exercises with sustained elevated heart rate (e.g., circuit training)
- Requires the watch to be worn properly for accurate readings

## Technical Requirements

- watchOS 8.0+
- HealthKit framework
- Active HKWorkoutSession for live data access

## Energy Considerations

Heart rate monitoring uses the watch's heart rate sensor continuously, which will impact battery life. The feature:
- Uses the standard workout heart rate sampling (once per second)
- Stops monitoring when the workout session ends
- Shares the same workout session used for general fitness tracking

Users should be aware that enabling this feature will have similar battery impact to running a workout in the Fitness app.
