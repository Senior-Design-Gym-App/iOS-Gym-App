import SwiftUI

struct OtherPage: View {
    
    var body: some View {
        List {
            Section {
                PermissionsInfo()
            } header: {
                Label("Permissions", systemImage: "eye")
            }
            Section {
                InternetConnectivity()
            } header: {
                Label("Connectivity", systemImage: "wifi")
            }
        }
    }
    
    private func InternetConnectivity() -> some View {
        Group {
            Label("Data is automatically synced through iCloud. Please do not use the app on multiple devices at the same time. Put the app in the background or close it if you wish to use it on another device.", systemImage: "cloud")
            Label("Data is provided by Apple Maps. A network connection is required for use in the Gyms, Social and Discover tabs.", systemImage: "globe")
        }
    }
    
    private func PermissionsInfo() -> some View {
        Group {
            Label("Your location is not required for use of this app. Your location is handled locally and is only used to find gyms on the map.", systemImage: "location")
            Label("Notifications are not required unless you use the rest timer function. If you disable notifications, the rest timer may not work correctly.", systemImage: "bell")
            Label("Your health data is only read from in this app and is not required. This data is used to view your progress alongside the progress you make on your workouts. This app does not modify your health data or share it. This is all handled locally.", systemImage: "heart.text.clipboard")
            Label("Your clipboard is only read when you tap the paste button.", systemImage: "document.on.clipboard")
        }
    }

}
