import SwiftUI

enum SortOption: String, CaseIterable {
    case lastModified = "Last Modified"
    case alphabetical = "Alphabetical"
    case lastCreated = "Last Created"
    case lastCheckIn = "Last Checked In"
}

struct SettingsView: View {
    
    @State private var notificationBody: String = ""
    @State var notificationOptions: [String]
    @State private var showingAddNotification: Bool = false
    @AppStorage("useLBs") private var useLBs = true
    @AppStorage("sortMethod") private var sortMethod: Bool = false
    @AppStorage("showRestTimer") private var showRestTimer: Bool = true
    @AppStorage("uploadWorkout") private var uploadWorkout: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    WorkoutOptions()
                } header: {
                    Label("Plan Options", systemImage: "list.bullet.clipboard.fill")
                }
                Section {
                    ProgressOptions()
                } header: {
                    Label("Progress Options", systemImage: "chart.bar.fill")
                }
                Section {
                    TimerOptions()
                } header: {
                    Label("Timer Options", systemImage: "alarm.fill")
                }
                Section {
                    NavigationLink {
                        SessionConfigurationView()
                    } label: {
                        Text("Session options")
                    }
                } header: {
                    Label("Session Options", systemImage: "timer")
                }
            }
            .navigationTitle("Settings")
            .alert("Custom Notification" ,isPresented: $showingAddNotification) {
                TextField("Notification Body", text: $notificationBody)
                Button("Save") {
                    notificationOptions.append(notificationBody)
                    NotificationManager.instance.SaveNotificationBodies(notififcationBody: notificationOptions)
                    notificationBody = ""
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    private func WorkoutOptions() -> some View {
        Group {
            Picker("Default Unit", selection: $useLBs) {
                Text("lbs").tag(true)
                Text("kgs").tag(false)
            }
        }
    }
    
    private func TimerOptions() -> some View {
        Group {
            Toggle("Show Rest Timer", isOn: $showRestTimer)
            if showRestTimer {
                ForEach(notificationOptions, id: \.self) { option in
                    HStack {
                        Text(option)
                        Spacer()
                        Button {
                            notificationOptions.removeAll(where: { $0 == option })
                            NotificationManager.instance.SaveNotificationBodies(notififcationBody: notificationOptions)
                        } label: {
                            Image(systemName: "trash")
                        }.tint(.red)
                    }
                }
                if notificationOptions.count < 9 {
                    Button {
                        showingAddNotification.toggle()
                    } label: {
                        Text("Add Custom Notification")
                    }
                }
            }
        }
    }
    
    private func ProgressOptions() -> some View {
        Group {
            Toggle("Upload Workout Check In", isOn: $uploadWorkout)
            Picker("Sort Dates", selection: $sortMethod) {
                Text("Recent First").tag(true)
                Text("Oldest First").tag(false)
            }
        }
    }
    
}
