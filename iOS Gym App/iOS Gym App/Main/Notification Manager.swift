import SwiftUI
import UserNotifications

final class NotificationManager {
    
    private let key = "savedStrings"
    static let instance = NotificationManager()
    
    private init() {
        RequestAuthorization { _, _ in
            
        }
    }
    
    private func RequestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let options: UNAuthorizationOptions = [.alert]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    func ScheduleNotification(seconds: Int) {
        CancelAllNotifications()
        let body = LoadNotificationBodyies().randomElement() ?? "Come to the Gym"
        let content = UNMutableNotificationContent()
        content.title = "Gym"
        content.body = body
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        let scheduledTime = Date().addingTimeInterval(TimeInterval(seconds))
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled in \(seconds) seconds.")
                UserDefaults.standard.set(scheduledTime.timeIntervalSince1970, forKey: "nextNotificationTime")
            }
        }
    }
    
    func CancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func LoadNotificationBodyies() -> [String] {
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func SaveNotificationBodies(notififcationBody: [String]) {
        UserDefaults.standard.set(notififcationBody, forKey: key)
    }
    
    func ScheduleNotificationsForSplit(split: Split) {
        guard split.active else { return }
        
        let center = UNUserNotificationCenter.current()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
                
        for workout in split.sortedWorkouts {
            guard let notif = workout.notificationType,
                  notif.type == .weekly else { continue }
            
            let dateComponents = notif.date
            
            var scheduledDates: [Date] = []
            
            let startDate = now
            
            for dayOffset in 0..<14 {
                if let checkDate = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: startDate)) {
                    let checkWeekday = calendar.component(.weekday, from: checkDate)
                    
                    if checkWeekday == dateComponents.weekday {
                        var fullComponents = calendar.dateComponents([.year, .month, .day], from: checkDate)
                        fullComponents.hour = dateComponents.hour
                        fullComponents.minute = dateComponents.minute
                        fullComponents.timeZone = calendar.timeZone
                        
                        if let scheduledDate = calendar.date(from: fullComponents) {
                            if scheduledDate > now {
                                scheduledDates.append(scheduledDate)
                            }
                        }
                    }
                }
            }
            
            for date in scheduledDates {
                let content = UNMutableNotificationContent()
                content.title = "Workout Reminder"
                content.body = GenerateReminderNames(name: workout.name)
                content.sound = .default
                
                let triggerComponents = calendar.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: date
                )
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: triggerComponents,
                    repeats: false
                )
                
                let identifier = "split_\(UUID().uuidString)"
                
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )
                
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func RemoveAllSplitNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix("split_") }
                .map { $0.identifier }
            
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    private func GenerateReminderNames(name: String) -> String {
        let options: [String] = [
            // Standard Motivational
            "Time to start \(name)",
            "Let’s get moving with \(name)",
            "Time to hit your \(name) session",
            "Get ready to crush \(name)",
            "Your \(name) workout starts now",
            "\(name) is calling—let’s go!",
            "Gear up—it’s time for \(name)",
            "Let’s kick off \(name) strong",
            "Ready to sweat? \(name) begins now",
            "Let’s make progress with \(name)",
            "Your journey continues with \(name)",
            "Let’s put in the work for \(name)",
            "Own this moment—start \(name)",
            "Let’s get after \(name)!",
            "Time to build strength with \(name)",
            "Let’s fire up for \(name)",
            "Start strong with \(name)",
            "Let’s make \(name) count",
            "Consistency starts with \(name)",
            "Let’s get in the zone for \(name)",
            "Unlock your strength with \(name)",
            "Momentum starts with \(name)",
            "Give it everything—start \(name)",
            "Let’s power through \(name)",
            "Your goals start with \(name)",

            // Short Starters
            "\(name) time!",
            "Go start \(name)!",
            "Move! \(name) awaits!",
            "Let’s do \(name)",
            "It’s \(name) o'clock",
            "Begin \(name)",
            "Go crush \(name)",
            "Start \(name) now",
            "Let’s hit \(name)",
            "Into \(name) we go",

            // Music-Themed
            "Queue the playlist—\(name) starts now",
            "Turn up the volume—it’s time for \(name)",
            "Let the beat guide your \(name) session",
            "Press play and start \(name)",
            "Let’s hit rhythm mode for \(name)",
            "Your \(name) soundtrack begins",
            "Drop the beat—begin \(name)",
            "Let music push you through \(name)",
            "Headphones in—time for \(name)",

            // Calm Style
            "Take a breath—start \(name) when you're ready",
            "Let’s ease into \(name)",
            "Settle your mind—it’s time for \(name)",
            "Move gently into \(name)",
            "Begin \(name) at your own pace",
            "Today is a good day for \(name)",
            "Focus and begin \(name)",
            "Let’s center ourselves and start \(name)",
            "Progress starts softly—with \(name)",
            "Flow into \(name)",

            // Funny
            "Time to do \(name)… again? Yep.",
            "Let’s pretend we love exercise—start \(name)",
            "Your muscles called—they miss \(name)",
            "\(name) won’t do itself",
            "Let’s go suffer—uh, I mean… start \(name)",
            "Activate gym gremlin mode: \(name)",
            "Time to disappoint the couch—start \(name)",
            "Start \(name)—your future self is watching",
            "Do \(name) so you can eat later without guilt",
            "Let’s go argue with gravity—begin \(name)"
        ]

        return options.randomElement()!
    }


}
