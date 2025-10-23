import SwiftUI

struct IncompleteSessionsView: View {
    
    let allSessions: [WorkoutSession]
    @Environment(SessionManager.self) private var sm: SessionManager
    @Environment(\.modelContext) private var context
    @State private var showAlert: Bool = false
    
    var incompleteSessions: [WorkoutSession] {
        allSessions.filter({ $0.completed == nil })
    }
    
    var body: some View {
        if incompleteSessions.isEmpty == false {
            VStack(alignment: .leading, spacing: 10) {
                ReusedViews.HorizontalHeader(text: "Incomplete Sessions", showNavigation: false)
                IncompleteSectionSession()
            }
            .alert("Session Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please end your current session before starting another.")
            }
        }
    }
        
    private func IncompleteSectionSession() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(incompleteSessions, id: \.self) { session in
                    Button {
                        if sm.session != nil {
                            showAlert = true
                            return
                        }
                        if let workout = session.workout {
                            
                            for exercise in workout.exercises ?? [] {
                                // Check if this workout has a session entry
                                let hasEntry = session.exercises?.contains(where: { entry in
                                    entry.exercise == exercise
                                }) ?? false
                                
                                if !hasEntry {
                                    sm.QueueExercise(exercise: exercise)
                                }
                            }
                        }
                        sm.session = session
                    } label: {
                        IncompleteSessionView(session: session)
                    }
                }
            }
        }.scrollIndicators(.hidden)
    }
    
    private func SessionButtonView(session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(session.name)")
                .font(.body)
                .tint(.primary)
            HStack {
                Text("\(session.started, formatter: DateHandler().dateFormatter())")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if session == sm.session {
                    Image(systemName: "waveform.mid")
                        .animation(.default, value: true)
                }
            }
        }
    }
    
    private func IncompleteSessionView(session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(ColorManager.shared.GetColor(key: session.id.hashValue.description))
                .scaledToFit()
                .aspectRatio(1.0, contentMode: .fit)
                .frame(minWidth: Constants.previewSize, maxWidth: 300, minHeight: Constants.previewSize, maxHeight: 300)
                .padding(.bottom, 5)
                .frame(minWidth: Constants.previewSize ,maxWidth: 300, minHeight: Constants.previewSize ,maxHeight: 300)
            ReusedViews.Description(topText: session.name, bottomText: "\(session.exercises?.count ?? 0) completed")
        }
    }
    
}
