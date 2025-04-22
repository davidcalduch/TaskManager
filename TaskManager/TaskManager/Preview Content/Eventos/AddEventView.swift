//
//  AddEventView.swift
//  TaskManager
//
//  Created by David Calduch on 23/3/25.
//

import SwiftUI

struct AddEventView: View {
    @EnvironmentObject var userSession: UserSession // para obtener userId

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var color: Int = 1
    
    @State private var showingAlert = false
    @State private var alertMessage = ""

    let eventService = EventService()

    let colors = [1: "Red", 2: "Yellow", 3: "Green"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Info")) {
                    TextField("Event name", text: $name)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }

                Section(header: Text("Date & Time")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("Color")) {
                    Picker("Color", selection: $color) {
                        ForEach(colors.keys.sorted(), id: \.self) { key in
                            Text(colors[key]!).tag(key)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Button("Add Event") {
                    addEvent()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .navigationTitle("Add Event")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Event Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func addEvent() {
        guard let userId = userSession.userId else {
            alertMessage = "User not logged in"
            showingAlert = true
            return
        }

        // Formato de fecha y hora
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let formattedTime = timeFormatter.string(from: time)

        // Crear evento
        let newEvent = Evento(
            id: nil,
            user: UserReference(id: userId),
            name: name,
            date: formattedDate,
            time: formattedTime,
            description: description,
            color: color
        )

        // Llamar al backend
        eventService.createEvent(event: newEvent) { success in
            DispatchQueue.main.async {
                if success {
                    alertMessage = "Event created successfully!"
                    name = ""
                    description = ""
                    date = Date()
                    time = Date()
                    color = 1
                } else {
                    alertMessage = "Failed to create event"
                }
                showingAlert = true
            }
        }
    }
}
