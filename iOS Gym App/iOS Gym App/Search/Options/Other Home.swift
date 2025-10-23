import SwiftUI

struct OtherHome: View {
    
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "Unknown"
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        LocalEULA()
                    } label: {
                        Text("General EULA")
                    }
                    NavigationLink {
                        OnlineEULA()
                    } label: {
                        Text("Online EULA")
                    }
                } header: {
                    Label("Agreements", systemImage: "book.pages")
                }
                Section {
                    NavigationLink {
                        SettingsView(notificationOptions: NotificationManager.instance.LoadNotificationBodyies())
                    } label: {
                        Text("Settings")
                    }
                    NavigationLink {
                        OtherPage()
                    } label: {
                        Text("Access & Network")
                    }
                } header: {
                    Label("Other", systemImage: "squareshape.split.2x2")
                }
                Section {
                    Text("Version: \(version).\(buildNumber)")
                    Text("Email: JPAmichi@gmail.com")
                } header: {
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("More")
        }
    }
    
}
