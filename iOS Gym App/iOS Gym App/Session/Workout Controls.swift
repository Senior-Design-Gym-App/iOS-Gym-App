import SwiftUI

struct SessionWorkoutControlView: View {
    
    let sessionManager: SessionManager
    let dismiss: () -> Void
    let endSession: () -> Void
    let deleteSession: () -> Void
    
    @AppStorage("showTimer") private var showTimer: Bool = true
    
    var body: some View {
        VStack(spacing: 30) {
            if let current = sessionManager.currentWorkout?.exercise.workoutEquipment {
                Image(systemName: current.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(70)
                    .border(Color.red, width: 1)
            } else {
                EmptyView()
                    .padding(70)
                    .border(Color.red, width: 1)
            }
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading) {
                    Text(sessionManager.currentWorkout?.exercise.name ?? "No Workout Selected")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("\(sessionManager.weight, specifier: "%.1f") kg \(sessionManager.reps) reps")
                        .font(.headline)
                        .fontWeight(.light)
                }
                Spacer()
                SessionControlMenu(sessionManager: sessionManager, dismiss: dismiss, endSession: endSession, deleteSession: deleteSession)
            }
        }
    }
    
}
