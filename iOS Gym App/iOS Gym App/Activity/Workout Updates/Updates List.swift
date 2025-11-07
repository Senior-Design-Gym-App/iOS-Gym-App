import SwiftUI

struct UpdatesListView: View {
    
    let allExercises: [Exercise]
    
    private var groupedUpdates: [String: [Exercise]] {
        Dictionary(grouping: allExercises) { exercise in
            let firstChar = exercise.name.prefix(1).uppercased()
            let char = firstChar.first ?? Character(" ")
            
            if char.isLetter {
                return String(char)
            } else {
                return "#" // Group all non-letters together
            }
        }
    }
    
    private var sortedLetters: [String] {
        let keys = groupedUpdates.keys
        let letters = keys.filter { $0 != "#" }.sorted()
        let hasNonLetters = keys.contains("#")
        
        return hasNonLetters ? letters + ["#"] : letters
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedLetters, id: \.self) { letter in
                    let updates = groupedUpdates[letter] ?? []
                    let sortedUpdates = updates.sorted { ($0.name) < ($1.name) }
                    
                    Section {
                        ForEach(sortedUpdates, id: \.self) { update in
                            NavigationLink {
                                ExerciseChanges(exercise: update)
                            } label: {
                                ReusedViews.ExerciseViews.ExerciseListPreview(exercise: update)
                            }
                        }
                    } header: {
                        Text(letter)
                    }
                    .sectionIndexLabel(letter)
                }
            }
            .navigationTitle("All Updates")
        }
    }
    
}
