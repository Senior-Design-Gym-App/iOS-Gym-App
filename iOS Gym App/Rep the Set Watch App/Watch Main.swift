//
//  Rep_the_SetApp.swift
//  Rep the Set Watch App
//
//  Created by Troy Madden on 10/7/25.
//

import SwiftUI

@main
struct Rep_the_Set_Watch_AppApp: App {
    @State private var sessionManager: WatchSessionManager
    
    init() {
        // Initialize WatchConnectivity on app launch
        _ = WatchConnectivityManager.shared
        
        // Initialize the session manager
        _sessionManager = State(initialValue: WatchSessionManager())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionManager)
        }
    }
}
