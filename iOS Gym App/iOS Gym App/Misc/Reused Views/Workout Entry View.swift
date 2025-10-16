import SwiftUI

struct WorkoutEntryView: View {
    
    let workout: WorkoutSessionEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.originalWorkout?.name ?? "Unknown")
            HStack {
                VStack(alignment: .leading) {
                    Text("Reps:")
                    Text("Weight:")
                }
                ForEach(workout.weight.indices, id: \.self) { set in
                    VStack(alignment: .leading) {
                        Text("\(workout.reps[set])")
                        Text("\(workout.weight[set])")
                    }
                }
            }
        }
    }
    
}
