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
    
    func SecondsUntilNextNotification() -> Int? {
        let now = Date().timeIntervalSince1970
        if let scheduledTime = UserDefaults.standard.value(forKey: "nextNotificationTime") as? TimeInterval {
            let remainingTime = Int(scheduledTime - now)
            return remainingTime > 0 ? remainingTime : nil
        }
        return nil
    }
    
    func LoadNotificationBodyies() -> [String] {
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func SaveNotificationBodies(notififcationBody: [String]) {
        UserDefaults.standard.set(notififcationBody, forKey: key)
    }

}
