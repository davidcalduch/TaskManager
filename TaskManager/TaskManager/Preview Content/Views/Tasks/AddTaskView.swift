import SwiftUI

struct AddTaskView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var priority: String = "Medium"
    @State private var completed: Bool = false
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showingAddEventView = false

    let priorities = ["Low", "Medium", "High"]
    let taskServiceInstance = TaskService()

    func validateInputs() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Title cannot be empty."
            return false
        }
        if description.count < 10 {
            alertMessage = "Description must be at least 10 characters long."
            return false
        }
        if dueDate < Date() {
            alertMessage = "Due date cannot be in the past."
            return false
        }
        return true
    }

    func addTask() {
        guard validateInputs() else {
            showingAlert = true
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dueDateString = formatter.string(from: dueDate)

        let newTask = Task1(
            id: nil,
            title: title,
            description: description,
            dueDate: dueDateString,
            priority: priority,
            completed: completed
        )

        taskServiceInstance.createTask(task: newTask) { success in
            DispatchQueue.main.async {
                if success {
                    alertMessage = "Task successfully added!"
                    title = ""
                    description = ""
                    dueDate = Date()
                    priority = "Medium"
                    completed = false
                } else {
                    alertMessage = "Failed to add task. Please try again."
                }
                showingAlert = true
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Enter task title", text: $title)
                        .autocapitalization(.words)
                        .padding()
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .padding()
                        .border(Color.gray, width: 1)
                }
                Section(header: Text("Due Date")) {
                    DatePicker("Select Due Date", selection: $dueDate, in: Date()..., displayedComponents: [.date])
                        .datePickerStyle(WheelDatePickerStyle())
                        .padding()
                }
                Section(header: Text("Priority")) {
                    Picker("Select Priority", selection: $priority) {
                        ForEach(priorities, id: \ .self) { priority in
                            Text(priority).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    Toggle("Mark as Completed", isOn: $completed)
                }
                Section {
                    Button(action: addTask) {
                        Text("Add Task")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(trailing: Button(action: {
                showingAddEventView = true
            }) {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(.blue)
            })
            .sheet(isPresented: $showingAddEventView) {
                AddEventView()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Task Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
