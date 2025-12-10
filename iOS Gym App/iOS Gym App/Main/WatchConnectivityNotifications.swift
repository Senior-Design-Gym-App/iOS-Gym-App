//
//  WatchConnectivityNotifications.swift
//  Shared
//
//  Notification names used for Watch Connectivity
//

import Foundation

#if !os(macOS) && !os(tvOS)
extension Notification.Name {
    static let liveSessionUpdated = Notification.Name("liveSessionUpdated")
    static let sessionActionReceived = Notification.Name("sessionActionReceived")
    static let watchRequestedWorkouts = Notification.Name("watchRequestedWorkouts")
    static let watchCompletedSession = Notification.Name("watchCompletedSession")
    static let workoutsReceived = Notification.Name("workoutsReceived")
    static let remoteSessionStarted = Notification.Name("remoteSessionStarted")
    static let workoutCanceledFromPhone = Notification.Name("workoutCanceledFromPhone")
    static let workoutEndedFromPhone = Notification.Name("workoutEndedFromPhone")
    static let heartRateAutoAdvance = Notification.Name("heartRateAutoAdvance")
}
#endif
