import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    var completed: Bool
}

struct CalendarTaskView: View {
    @State private var selectedDate = Date()
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = ""
    @EnvironmentObject var userSession: UserSession
    @State private var alertMessage: String = ""
    @State private var showingAlert: Bool = false
    private let taskService = TaskService()

    private var tasksForSelectedDate: [Task] {
        tasks.filter { task in
            Calendar.current.isDate(task.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Gestión de Tareas")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    // Botón para redirigir a la vista de calendario
                    NavigationLink(destination: WeeklyCalendarView()) {
                        Image(systemName: "calendar")
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding(.trailing)
                    }
                }
                .padding()

                HStack {
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    Spacer()
                    Text("\(monthYearFormatter.string(from: selectedDate))")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
                .padding()

                DatePicker(
                    "Selecciona una fecha",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

                List {
                    if tasksForSelectedDate.isEmpty {
                        Text("No hay tareas para esta fecha")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(tasksForSelectedDate) { task in
                            HStack {
                                Text(task.title)
                                    .strikethrough(task.completed, color: .red)
                                Spacer()
                                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.completed ? .green : .gray)
                            }
                            .onTapGesture {
                                toggleTaskCompletion(task: task)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                fetchTasks()
            }
        }
    }

    private func fetchTasks() {
        taskService.fetchTasks { fetchedTasks in
            self.tasks = fetchedTasks.map { task1 in
                Task(
                    title: task1.title,
                    date: convertStringToDate(task1.dueDate), // ✅ Convierte la fecha correctamente
                    completed: task1.completed
                )
            }
            print("✅ Tareas recibidas: \(self.tasks)")
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        guard let userId = userSession.userId else {
                alertMessage = "User not logged in."
                showingAlert = true
                return
            }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dueDateString = formatter.string(from: selectedDate) // ✅ Enviar solo la fecha
        

        let newTask = Task1(
            id: nil, // El backend asignará el ID
            title: newTaskTitle,
            description: "",
            dueDate: dueDateString,
            priority: "Medium",
            completed: false,
            user: UserReference(id: userId)
        )

        taskService.createTask(task: newTask) { success in
            if success {
                fetchTasks() // Recargar tareas después de agregar una nueva
                newTaskTitle = "" // Limpiar el campo de texto
            }
        }
    }

    private func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].completed.toggle()
        }
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

struct CalendarTaskView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarTaskView()
    }
}

private func convertStringToDate(_ dateString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd" // 📆 Asegúrate de que coincide con el formato del backend
    return formatter.date(from: dateString) ?? Date() // Devuelve la fecha actual si falla
}

