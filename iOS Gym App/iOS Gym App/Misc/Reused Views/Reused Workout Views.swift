import SwiftUI

extension ReusedViews {
    
    struct ExerciseViews {
        
        static func WorkoutInfo(exercise: Exercise) -> some View {
            HStack {
                RoundedRectangle(cornerRadius: Constants.smallRadius)
                    .fill(ColorManager.shared.GetColor(key: exercise.id.hashValue.description))
                    .frame(width: Constants.smallListSize, height: Constants.smallListSize)
                    .overlay(alignment: .center) {
                        Image(systemName: exercise.workoutEquipment?.imageName ?? "dumbbell")
                            .foregroundStyle(Constants.iconColor)
                    }
                VStack(alignment: .leading, spacing: 0) {
                    Text(exercise.name)
                    Text("\(exercise.setData.count) set\(exercise.setData.count == 1 ? "" : "s")")
                        .font(.callout)
                        .fontWeight(.thin)
                }
            }
        }
        
        static func WorkoutGridPreview(exercise: Exercise, bottomText: String) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(ColorManager.shared.GetColor(key: exercise.id.hashValue.description))
                    Image(systemName: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                        .clipShape(.rect(cornerRadius: 10))
                        .foregroundStyle(Constants.iconColor)
                }
                .aspectRatio(1.0, contentMode: .fit)
                .frame(minWidth: Constants.previewSize, maxWidth: 300, minHeight: Constants.previewSize, maxHeight: 300)
                .padding(.bottom, 5)
                ReusedViews.Description(topText: exercise.name, bottomText: bottomText)
            }
            .padding(.bottom)
        }
        
    }
    
    struct WorkoutViews {
        
        static func DayGridPreview(workout: Workout, bottomText: String) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(ColorManager.shared.GetColor(key: workout.id.hashValue.description))
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.bottom, 5)
                    .frame(minWidth: Constants.previewSize ,maxWidth: 300, minHeight: Constants.previewSize ,maxHeight: 300)
                ReusedViews.Description(topText: workout.name, bottomText: bottomText)
            }
            .padding(.bottom)
        }
        
    }
    
    struct SplitViews2 {
        
        static func SplitGridPreview(split: Split, bottomText: String) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                SplitViews.CardView(split: split, size: Constants.gridSize)
                    .padding(.bottom, 5)
                ReusedViews.Description(topText: split.name, bottomText: bottomText)
            }
            .padding(.bottom)
        }
        
    }
    
    
}
