import SwiftUI

struct AddTaskView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var priority: String = "Medium"
    @State private var completed: Bool = false
    @State private var alertMessage = ""
    @State private var showingAlert = false

    let priorities = ["Low", "Medium", "High"]
    let taskServiceInstance = TaskService()

    func addTask() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"  // Solo la fecha, sin hora.
        formatter.timeZone = TimeZone(secondsFromGMT: 0)  // UTC
        let dueDateString = formatter.string(from: dueDate)

        // Crea la tarea sin el `id`, que es `nil`.
        let newTask = Task1(
            id: nil,  // No enviamos el `id`, el backend lo generará.
            title: title,
            description: description,
            dueDate: dueDateString,
            priority: priority,
            completed: completed
        )

        // Imprimir los datos para asegurarnos de que el formato es correcto.
       /* print("📤 Enviando tarea:")
        print("📌 ID: \(newTask.id ?? -1)")
        print("📌 Title: \(newTask.title)")
        print("📌 Description: \(newTask.description)")
        print("📌 DueDate: \(newTask.dueDate)")
        print("📌 Priority: \(newTask.priority)")
        print("📌 Completed: \(newTask.completed)")*/

        taskServiceInstance.createTask(task: newTask) { success in
            DispatchQueue.main.async {
                alertMessage = success ? "Task successfully added!" : "Failed to add task. Please try again."
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
                    DatePicker("Select Due Date", selection: $dueDate, displayedComponents: [.date])
                        .datePickerStyle(WheelDatePickerStyle())
                        .padding()
                }

                Section(header: Text("Priority")) {
                    Picker("Select Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { priority in
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
