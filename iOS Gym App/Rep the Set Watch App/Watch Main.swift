//
//  Rep_the_SetApp.swift
//  Rep the Set Watch App
//
//  Created by Troy Madden on 10/7/25.
//

import SwiftUI

@main
struct Rep_the_Set_Watch_AppApp: App {
    init() {
        // Initialize WatchConnectivity on app launch
        _ = WatchConnectivityManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
