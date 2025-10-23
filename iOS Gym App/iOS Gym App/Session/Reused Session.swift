import SwiftUI

struct SessionControlMenu: View {
    
    let sessionManager: SessionManager
    let dismiss: () -> Void
    let endSession: () -> Void
    let deleteSession: () -> Void
    
    @State private var renameText: String = ""
    @State private var showRenameAlert: Bool = false
    @AppStorage("showTimer") private var showTimer: Bool = true
    
    var body: some View {
        Menu {
            WorkoutControlSection()
            SessionOptionsSection()
        } label: {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .alert("Edit Workout Name", isPresented: $showRenameAlert) {
            TextField("Enter new name", text: $renameText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Ok", role: .confirm) {
                sessionManager.session?.name = renameText
            }
        }
    }
    
    private func WorkoutControlSection() -> some View {
        Section {
            if let name = sessionManager.session?.name {
                RenameSessionButton(name: name)
            }
            if let currentWorkout = sessionManager.currentWorkout, showTimer {
                RestartTimerButton(current: currentWorkout)
            }
        } header: {
            Text("Workout Control")
        }
    }
    
    private func SessionOptionsSection() -> some View {
        Section {
            PreviousWorkoutButton()
            EndSessionButton()
            DiscardSessionButton()
        } header: {
            Text("Session Options")
        }
    }
    
    private func RestartTimerButton(current: SessionData) -> some View {
        Button {
            sessionManager.StartTimer(exercise: current.exercise, entry: current.entry, currentSet: current.entry.weight.count + 1)
        } label: {
            Label("Restart Timer", systemImage: "arrow.trianglehead.2.counterclockwise")
        }
    }
    
    private func PreviousWorkoutButton() -> some View {
        Button {
            sessionManager.SessionPreviousWorkout()
        } label: {
            Label("Previous Workout", systemImage: "backward.end")
        }
    }
    
    private func RenameSessionButton(name: String) -> some View {
        Button {
            renameText = name
            showRenameAlert = true
        } label: {
            Label("Rename Session", systemImage: "pencil")
        }
    }
    
    private func EndSessionButton() -> some View {
        Button {
            endSession()
        } label: {
            Label("End Session", systemImage: "stop")
        }
    }
    
    private func DissmissButton() -> some View {
        Button {
            dismiss()
        } label: {
            Label("Dismiss", systemImage: "octagon.and.xmark")
        }
    }
    
    private func DiscardSessionButton() -> some View {
        Button {
            deleteSession()
        } label: {
            Label("Discard Session", systemImage: "trash")
        }
    }
    
}
