//
//  SettingsView.swift
//  TaskManager
//
//  Created by David Calduch on 2/1/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var userName = "David Calduch"
    @State private var userEmail = "david@example.com"
    @State private var userPassword = "********"
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
                            Text(userName)
                                .font(.headline)
                            Text(userEmail)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        Spacer()
                        Button(action: {
                            // Aquí podrías agregar una acción para cambiar la foto del avatar
                        }) {
                            Text("Change Photo")
                                .foregroundColor(.blue)
                        }
                    }
                }

                Section(header: Text("User Information")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(userName)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(userEmail)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Password")
                        Spacer()
                        Text(userPassword)
                            .foregroundColor(.gray)
                    }
                }

                Section {
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                    }
                }

                Section(header: Text("Other Settings")) {
                    Button(action: {
                    }) {
                        Text("Change Language")
                    }
                    Button(action: {
                    }) {
                        Text("Notifications")
                    }
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
