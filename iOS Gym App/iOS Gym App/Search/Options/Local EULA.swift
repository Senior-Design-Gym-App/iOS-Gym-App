import SwiftUI

struct LocalEULA: View {
    
    var body: some View {
        NavigationStack {
            List {
                LicenseGrant()
                OfflineFeatures()
                DataUsageAndPrivacy()
                Disclaimers()
                LimitationOfLiability()
            }
            .navigationTitle("EULA")
        }
    }
    
    private func LicenseGrant() -> some View {
        Section {
            Text("You are granted a limited, non-exclusive, non-transferable, revocable license to use Let’s Gym for personal, non-commercial purposes on your personal device. This license does not allow distribution or modification of the app.")
        } header: {
            Text("License Grant")
        }
    }
    
    private func OfflineFeatures() -> some View {
        Section {
            Text("This app allows you to: \nTrack your daily workouts and changes over time \nView your workout history and improvements \nAccess your HealthKit data (BMI, weight, and body fat), with read-only access.")
        } header: {
            Text("Offline Features")
        }
    }
    
    private func DataUsageAndPrivacy() -> some View {
        Section {
            Text("We do not collect, transmit, or store any personal data in offline mode. Health data is read from HealthKit with your explicit permission and is used solely within the app to enhance your tracking experience.")
        } header: {
            Text("Data Usage and Privacy")
        }
    }
    
    private func Disclaimers() -> some View {
        Section {
            Text("Let’s Gym is provided “as is,” with no guarantees of accuracy, uptime, or suitability for your specific fitness needs. Always consult with a medical professional before beginning any workout plan.")
        } header: {
            Text("Disclaimers")
        }
    }
    
    private func LimitationOfLiability() -> some View {
        Section {
            Text("We are not liable for any damage, injury, or data loss resulting from the use of the app in offline mode. You are responsible for backing up your data.")
        } header: {
            Text("Limitation of Liability")
        }
    }
    
}
