import SwiftUI

extension ReusedViews {
    
    struct Pickers {
        
        static func WorkoutMenu(sortType: Binding<WorkoutSortTypes>, viewType: Binding<WorkoutViewTypes>) -> some View {
            Menu {
                Picker("View Type", selection: viewType) {
                    ForEach(WorkoutViewTypes.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.imageName).tag(type)
                    }
                }
                Picker("Sort Method", selection: sortType) {
                    Text("A-Z").tag(WorkoutSortTypes.alphabetical)
                    Text("Created").tag(WorkoutSortTypes.created)
                    Text("Modified").tag(WorkoutSortTypes.modified)
                }
            } label: {
                Label("Options", systemImage: "ellipsis")
            }
        }
        
        static func TimerTypePicker(type: Binding<TimerType>) -> some View {
            Picker("Timer Type", selection: type) {
                ForEach(TimerType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.imageName).tag(type)
                }
            }
        }
        
        static func DisplayTypePicker(type: Binding<DonutDisplayType>, exempt: DonutDisplayType) -> some View {
            Picker("Displayed Data", selection: type) {
                ForEach(DonutDisplayType.allCases, id: \.self) { type in
                    if type != exempt {
                        Text(type.rawValue).tag(type)
                    }
                }
            }.pickerStyle(.segmented)
        }
        
        struct WorkoutNotificationPicker: View {
            
            @Binding var hour: Int
            @Binding var minute: Int
            @Binding var period: DayPeriod
            
            var body: some View {
                Group {
                    Picker("Day Period", selection: $period) {
                        ForEach(DayPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    switch period {
                    case .am, .pm:
                        HourPicker(maxHour: 13)
                    case .day:
                        HourPicker(maxHour: 25)
                    }
                    Picker("Minute", selection: $minute) {
                        ForEach(0..<12, id: \.self) { minute in
                            Text("\(minute * 5)").tag(minute * 5)
                        }
                    }
                }.onChange(of: period) {
                    if period == .day && hour < 12 {
                        hour += 12
                    } else if (period == .am || period == .pm) && hour > 12 {
                        hour -= 12
                    }
                }
            }
            
            private func HourPicker(maxHour: Int) -> some View {
                Picker("Hour", selection: $hour) {
                    ForEach(1..<maxHour, id: \.self) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }
            }

        }
        
    }
    
}
