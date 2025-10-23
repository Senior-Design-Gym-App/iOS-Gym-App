import SwiftUI

struct OnlineEULA: View {
    
    var body: some View {
        NavigationStack {
            List {
                LicenseGrant()
                YourResponsibilities()
                OnlineFeatures()
                CommunityGuidelines()
                ContentOwnership()
                Disclaimers()
                LimitationOfLiability()
            }
            .navigationTitle("Online EULA")
        }
    }
    
    private func LicenseGrant() -> some View {
        Section {
            Text("You are granted a limited, non-exclusive, non-transferable, revocable license to use Let’s Gym for personal, non-commercial purposes on your personal device. This license does not allow distribution or modification of the app.")
        } header: {
            Text("License Grant")
        }
    }
    
    private func YourResponsibilities() -> some View {
        Section {
            Text("To access online features, you may be required to create an account. You agree to use the platform in compliance with all applicable laws and regulations.")
        } header: {
            Text("Your Responsibilities")
        }
    }
    
    private func OnlineFeatures() -> some View {
        Section {
            Text("With an account, you can: View and share workouts with friends. Access and download plans from other users. Upload your own workout plans, which may be downloaded, modified, and reuploaded by other users. Search local gyms, view their user base, and see which friends are members. Add gyms to your profile and show your membership duration.")
        } header: {
            Text("Online Features")
        }
    }
    
    private func CommunityGuidelines() -> some View {
        Section {
            Text("You agree not to: Post or share content that is offensive, harmful, or illegal. Misrepresent your identity or harass other users. Exploit or misuse the app for commercial gain.")
        } header: {
            Text("Community Guidelines")
        }
    }
    
    private func ContentOwnership() -> some View {
        Section {
            Text("By uploading workout plans, you agree to allow other users to download, modify, and reupload your content. Let’s Gym is not responsible for how users use or modify shared content.")
        } header: {
            Text("Content Ownership")
        }
    }
    
    private func Disclaimers() -> some View {
        Section {
            Text("Let’s Gym makes no guarantees regarding the accuracy of shared plans, user data, or third-party gym information. Use of online features is at your own risk.")
        } header: {
            Text("Disclaimers")
        }
    }
    
    private func LimitationOfLiability() -> some View {
        Section {
            Text("To the maximum extent permitted by law, Let’s Gym shall not be liable for any direct or indirect damages related to online interactions, data misuse, or service interruptions.")
        } header: {
            Text("Limitation of Liability")
        }
    }
    
}
