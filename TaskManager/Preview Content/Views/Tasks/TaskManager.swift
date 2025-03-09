//
//  TaskManager.swift
//  TaskManager
//
//  Created by David Calduch on 2/1/25.
//

import SwiftUI

struct TaskManager: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
struct MainTabView: View {
    var body: some View {
        TabView {
            CalendarTaskView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            AddTaskView()
                .tabItem {
                    Label("Add Task", systemImage: "plus.circle")
                }
            PendingTasksView()
                .tabItem {
                    Label("Pending Tasks", systemImage: "checkmark.circle")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.blue)
    }
}


