import SwiftUI
import SwiftData

struct SearchHomeView: View {
    
    @State private var searchText: String = ""
    @Query private var exercises: [Exercise]
    @Query private var workouts: [Workout]
    @Query private var splits: [Split]
    @Query private var allSessions: [WorkoutSession]
    
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "Unknown"
    
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    
    var body: some View {
        NavigationStack {
            GlassEffectContainer {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        WorkoutsLink()
                    }
                }
            }
            .padding(.horizontal)
            .toolbarTitleDisplayMode(.inlineLarge)
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Search")
        }
    }
    
    private func TitleCard() -> some View {
        RoundedRectangle(cornerRadius: Constants.homeRadius)
            .fill(Constants.mainAppTheme)
            .overlay(alignment: .top) {
                Text("Lets Gym 2")
                    .fontWeight(.semibold)
                    .font(.largeTitle)
                    .padding(.top)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, minHeight: 350)
    }
    
    private func WorkoutsLink() -> some View {
        Group {
            NavigationLink {
                AllExerciseView()
            } label: {
                RectangleGridView(text: "Workouts", id: "All Workouts")
            }
            NavigationLink {
                AllWorkoutsView()
            } label: {
                RectangleGridView(text: "Workout Days", id: "All Days")
            }
            NavigationLink {
                AllWorkoutSplitsView()
            } label: {
                RectangleGridView(text: "Splits", id: "All Splits")
            }
            NavigationLink {
                OtherHome()
            } label: {
                RectangleGridView(text: "Other", id: "Other")
            }
            NavigationLink {
                DeletePage()
            } label: {
                RectangleGridView(text: "Delete", id: "Delete")
            }
        }
    }
    
    private func ProgressLink() -> some View {
        Group {
            NavigationLink {
                
            } label: {
                
            }
            NavigationLink {
                
            } label: {
                
            }
            NavigationLink {
                
            } label: {
                
            }
            NavigationLink {
                
            } label: {
                
            }
        }
    }
    
    private func RectangleGridView(text: String, id: String) -> some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .fill(ColorManager.shared.GetColor(key: id).gradient)
            .frame(minHeight: 100)
            .overlay(alignment: .bottomLeading) {
                Text(text)
                    .foregroundStyle(Color.white)
                    .fontWeight(.medium)
                    .font(.title3)
                    .padding()
            }
    }
    
    private func SetGridView(text: String, color: Color) -> some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .fill(color)
            .frame(minHeight: 100)
            .overlay(alignment: .bottomLeading) {
                Text(text)
                    .foregroundStyle(Color.white)
                    .fontWeight(.medium)
                    .font(.title3)
                    .padding()
            }
    }
    
}
