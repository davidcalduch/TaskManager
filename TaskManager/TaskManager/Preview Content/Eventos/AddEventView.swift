//
//  AddEventView.swift
//  TaskManager
//
//  Created by David Calduch on 23/3/25.
//

import SwiftUI

struct AddEventView: View {
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var eventDate: Date = Date()
    @State private var showingDatePicker = false
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var selectedColor: Color = .blue
    
    let priorityColors: [(color: Color, name: String)] = [(.green, "Low"), (.yellow, "Medium"), (.red, "High")]
    
    func validateInputs() -> Bool {
        if eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Event name cannot be empty."
            return false
        }
        return true
    }
    
    func addEvent() {
        guard validateInputs() else {
            showingAlert = true
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let eventDateTime = dateFormatter.string(from: eventDate)
        
        print("📅 Event: \(eventName), \(eventDateTime), Color: \(selectedColor)")
        
        alertMessage = "Event successfully added!"
        showingAlert = true
        
        // Clear form
        eventName = ""
        eventDescription = ""
        eventDate = Date()
        selectedColor = .blue
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Enter event name", text: $eventName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextEditor(text: $eventDescription)
                    .frame(height: 80)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .padding(.horizontal)
                
                Button(action: { showingDatePicker.toggle() }) {
                    HStack {
                        Text("Select Date & Time")
                        Spacer()
                        Text("\(eventDate, formatter: DateFormatter.shortDateTime)")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.systemGray6)))
                    .padding(.horizontal)
                }
                
                if showingDatePicker {
                    DatePicker("Select Date & Time", selection: $eventDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding(.horizontal)
                }
                
                Text("Priority Level")
                    .font(.headline)
                    .padding(.top)
                
                HStack {
                    ForEach(priorityColors, id: \ .name) { color in
                        Circle()
                            .fill(color.color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == color.color ? Color.black : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedColor = color.color
                            }
                    }
                }
                .padding(.bottom)
                
                Button(action: addEvent) {
                    Text("Save Event")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Event Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("New Event")
        }
    }
}

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}
