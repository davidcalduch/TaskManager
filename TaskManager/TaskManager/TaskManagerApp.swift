//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by David Calduch on 2/1/25.
//

import SwiftUI

@main
struct TaskManagerApp: App {
    @StateObject private var userSession = UserSession()

    var body: some Scene {
        WindowGroup {
            if userSession.isLoggedIn {
                MainTabView()
                    .environmentObject(userSession)
            } else {
                LoginView()
                    .environmentObject(userSession)
            }
        }
    }
}
