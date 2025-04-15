//
//  SettingsView.swift
//  TaskManager
//
//  Created by David Calduch on 2/1/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSession: UserSession
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var avatarImage: Image? = Image(systemName: "person.crop.circle.fill")

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        avatarImage?
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                            .padding(.trailing, 10)
                        VStack(alignment: .leading) {
                            Text(userSession.name)
                                .font(.headline)
                            Text(userSession.email)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        Spacer()
                        Button("Change Photo") {
                            // Acción de cambiar foto
                        }
                        .foregroundColor(.blue)
                    }
                }

                Section(header: Text("User Information")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(userSession.name)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(userSession.email)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Password")
                        Spacer()
                        Text(userSession.password)
                            .foregroundColor(.gray)
                    }
                }

                Section {
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                    }
                }

                Section(header: Text("Other Settings")) {
                    Button("Change Language") {}
                    Button("Notifications") {}
                }
            }
            .navigationTitle("Settings")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
