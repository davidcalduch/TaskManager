import SwiftUI

struct Task: Identifiable, Decodable {
    let id: Int   // Cambiado de UUID a Int
    let title: String
    let dueDate: String  // Asegúrate de que la propiedad coincida con el JSON
    var completed: Bool
    let user: UserReference  // Suponiendo que tienes una estructura para el usuario
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
            Calendar.current.isDate(convertStringToDate(task.dueDate), inSameDayAs: selectedDate)
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

    func fetchTasks() {
        guard let userId = userSession.userId else { return }

        guard let url = URL(string: "http://localhost:8080/tasks/user/\(userId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"  // Verifica que el método es GET

        // Agregar autenticación básica si es necesario
        let username = "david"  // Cambia a tu usuario
        let password = "Pitita_44"  // Cambia a tu contraseña
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else { return }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let decoder = JSONDecoder()

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error en la petición: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Respuesta no válida del servidor")
                return
            }
            if httpResponse.statusCode == 200 {
                do {
                    let decoded = try decoder.decode([Task].self, from: data!)
                    DispatchQueue.main.async {
                        self.tasks = decoded
                    }
                } catch {
                    print("❌ Error al decodificar: \(error)")
                }
            } else {
                print("❌ Error en la respuesta HTTP: \(httpResponse.statusCode)")
            }
        }.resume()
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
    let isoFormatter = ISO8601DateFormatter()
    if let date = isoFormatter.date(from: dateString) {
        return date
    }
    
    // Si el formato no es ISO8601, intenta con un formato más estándar
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Ajusta esto al formato correcto de la fecha que recibes
    return formatter.date(from: dateString) ?? Date() // Devuelve la fecha actual si falla
}
