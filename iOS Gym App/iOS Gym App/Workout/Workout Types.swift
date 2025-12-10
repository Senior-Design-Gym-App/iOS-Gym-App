import Foundation
import SwiftUI

enum WorkoutSortTypes: String, CaseIterable, Identifiable {
    
    case alphabetical       = "A-Z"
    case created            = "Created"
    case modified           = "Modified"
    
    var id : String { rawValue }
    
}

enum WorkoutViewTypes: String, CaseIterable, Identifiable {
    
    case grid              = "Grid"
    case verticalList      = "List"
    
    var id : String { rawValue }
    
    var imageName: String {
        switch self {
        case .verticalList:
            "list.bullet"
        case .grid:
            "square.grid.2x2"
        }
    }
    
}

struct WorkoutNotificationType: Codable, Equatable {
    
    let type: NotificationType
    let period: DayPeriod
    let day: DayofWeek
    let minute: Int
    let hour: Int
    
    var adjustedHour: Int {
        switch period {
        case .am:
            return hour == 12 ? 0 : hour  // 12 AM is 0 (midnight)
        case .pm:
            return hour == 12 ? 12 : hour + 12  // 12 PM stays 12 (noon), others add 12
        case .day:
            return hour  // 24-hour format, use as-is
        }
    }
    
    var date: DateComponents {
        var comps = DateComponents()
        comps.hour = adjustedHour
        comps.minute = minute
        comps.weekday = day.dayNumber
        return comps
    }
    
}

enum NotificationType: String, Codable, CaseIterable {
    
    case weekly     = "Weekly"
    case disabled   = "Disabled"
    
}

enum DayofWeek: String, Codable, CaseIterable, Identifiable {
    
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    
    var id: String { rawValue }
    
    var dayNumber: Int {
        switch self {
        case .sunday:
            return 1
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .saturday:
            return 7
        }
    }
    
}

enum DayPeriod: String, Codable, CaseIterable {
    
    case am     = "AM"
    case pm     = "PM"
    case day    = "24 Hour"
    
}

enum WorkoutItemType: String {
    
    case exercise   = "Exercise"
    case workout    = "Workout"
    case split      = "Split"
    case session    = "Session"
    case oneRepMax  = "One Rep Max"
    
    var listLabel: String {
        switch self {
        case .exercise:
            return "Sets"
        case .workout:
            return "Exercises"
        case .split:
            return "Workouts"
        case .session:
            return "Sessions"
        case .oneRepMax:
            return "One Rep Maxes"
        }
    }
    
    var deleteOption: String {
        switch self {
        case .exercise:
            return "This will be removed from all sessions and all history will be lost."
        case .workout:
            return "This will be removed from all sessions and all splits. The exercises will not be deleted."
        case .split:
            return "This will be removed but all the workouts will still remain."
        case .session:
            return "This will be removed from your sessions and all session progress will be lost."
        case .oneRepMax:
            return "This will he removed from your exercise history."
        }
    }
    
}

extension Workout {
    
    var notificationType: WorkoutNotificationType? {
        guard !notificationString.isEmpty,
              let data = notificationString.data(using: .utf8),
              let type = try? JSONDecoder().decode(WorkoutNotificationType.self, from: data) else {
            return nil
        }
        return type
    }
    
    func encodeNotificationType(type: WorkoutNotificationType) {
        do {
            let data = try JSONEncoder().encode(type)
            notificationString = String(decoding: data, as: UTF8.self)
        } catch {
            print("failed to encode notification type")
        }
    }
    
}

extension Exercise {
    
    var icon: Image {
        if let equipment = workoutEquipment?.imageName {
            Image(systemName: equipment)
        } else {
            Image(systemName: Constants.exerciseIcon)
        }
    }
    
}

struct OneRepMaxData: Identifiable, Hashable {
    
    let id = UUID()
    let entry: WeightEntry
    let session: WorkoutSession?
    
    
}
