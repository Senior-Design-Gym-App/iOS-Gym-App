//
//  SessionView.swift
//  LetsGym2
//
//  Created by Matthew Jacobs on 9/16/25.
//


import SwiftUI
import SwiftData

struct SessionRecap: View {
    
    @State var session: WorkoutSession
    @State var sessionName: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                AboutSessionView()
                SessionDataView()
                SaveOptions()
            }
            .navigationTitle(session.name)
            .navigationSubtitle("Session Recap")
        }
    }
    
    private func AboutSessionView() -> some View {
        Section {
            TextField("Session Name", text: $sessionName)
            Text("Started: \(CheckInDateFormatter(date: session.started))")
            if let endDate = session.completed {
                Text("Ended: \(CheckInDateFormatter(date: endDate))")
            } else {
                Text("Session not yet completed.")
            }
//            if let gymID = session.gym {
//                GymAddress(gym: <#T##MKMapItem#>)
//            }
        } header: {
            Text("About")
        }
    }
    
    private func SessionDataView() -> some View {
        Section {
            ForEach(session.exercises ?? [], id: \.self) { entry in
                EntryView(entry: entry)
            }
        } header: {
            Text("Session Data")
        }
    }
    
    private func SaveOptions() -> some View {
        Section {
            Button {
                session.name = sessionName
                try? context.save()
                dismiss()
            } label: {
                Label("Update & Exit", systemImage: "square.and.arrow.down.badge.checkmark")
            }
            Button {
                context.delete(session)
                try? context.save()
                dismiss()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .foregroundStyle(.red)
        } header: {
            Text("Save Options")
        }
    }
    
    @ViewBuilder
    private func EntryView(entry: WorkoutSessionEntry) -> some View {
        if let workout = entry.exercise?.updateData {
            NavigationLink {
//                ExerciseChanges(exercise: e)
//                WorkoutUpdateView(workout: workout)
            } label: {
                WorkoutEntryView(workout: entry)
            }
        } else {
            WorkoutEntryView(workout: entry)
        }
    }
    
    private func CheckInDateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, h:mm a, yyyy"
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
}
