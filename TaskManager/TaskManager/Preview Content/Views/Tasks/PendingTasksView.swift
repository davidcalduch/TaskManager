import SwiftUI
import Foundation

struct UserTask: Identifiable, Codable {
    var id: Int
    var title: String
    var dueDate: String
    var completed: Bool

    var date: Date {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dueDate) {
            return date
        }
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = fallbackFormatter.date(from: dueDate) {
            return date
        }
        return Date()
    }
}

struct PendingTasksView: View {
    @State private var tasks: [UserTask] = []
    @State private var isLoading = true
    
    // Assuming userSession is available in the environment or elsewhere
    @EnvironmentObject var userSession: UserSession

    var groupedTasks: [String: [UserTask]] {
        Dictionary(grouping: tasks) { task in
            dayOfWeekFormatter.string(from: task.date)
        }
    }

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Cargando tareas...")
                    .navigationTitle("Tareas Pendientes")
            } else {
                List {
                    ForEach(groupedTasks.keys.sorted(), id: \.self) { day in
                        Section(header: Text(day).font(.headline)) {
                            ForEach(groupedTasks[day]!) { task in
                                EventRow(event: task, toggleCompletion: {
                                    toggleTaskCompletion(task: task)
                                })
                            }
                        }
                    }
                }
                .navigationTitle("Tareas Pendientes")
            }
        }
        .onAppear(perform: fetchTasks)
    }

    private func toggleTaskCompletion(task: UserTask) {
        guard let url = URL(string: "http://localhost:8080/tasks/\(task.id)") else { return }

        // Actualizamos el estado de la tarea (completed)
        var updatedTask = task
        updatedTask.completed.toggle()

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Asegúrate de que las credenciales sean correctas
        let username = "david"  // Cambia a tu usuario
        let password = "Pitita_44"  // Cambia a tu contraseña
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else { return }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        // Convertimos el objeto en JSON para enviar en la solicitud
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(updatedTask) else { return }

        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error al realizar la solicitud PUT: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                        tasks[index].completed = updatedTask.completed
                    }
                }
            } else {
                print("❌ Error al actualizar la tarea: \(response.debugDescription)")
            }
        }.resume()
    }

    private func fetchTasks() {
        guard let userId = userSession.userId else {
            print("❌ User ID no disponible")
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/tasks/user/\(userId)") else { return }

        let username = "david"
        let password = "Pitita_44"
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else { return }
        let base64LoginString = loginData.base64EncodedString()

        var request = URLRequest(url: url)
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
            if httpResponse.statusCode == 401 {
                print("❌ No autorizado (401). Verifique sus credenciales.")
                return
            }
            guard httpResponse.statusCode == 200 else {
                print("❌ Error HTTP: \(httpResponse.statusCode)")
                return
            }
            if let data = data {
                do {
                    let decoded = try decoder.decode([UserTask].self, from: data)
                    DispatchQueue.main.async {
                        self.tasks = decoded
                        self.isLoading = false
                    }
                } catch {
                    print("❌ Error al decodificar: \(error), data: \(String(data: data, encoding: .utf8) ?? "N/A")")
                }
            }
        }.resume()
    }

    private var dayOfWeekFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }

    private func convertDateToUTC(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")  // Asegúrate de convertir la fecha a UTC
        return formatter.string(from: date)
    }

    func convertUTCToLocal(utcDateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = formatter.date(from: utcDateString) else { return "" }

        formatter.timeZone = TimeZone.current // Convertir a la zona horaria local
        formatter.dateStyle = .long  // Mostrar la fecha en el formato "día, mes, año"
        return formatter.string(from: date)
    }
}

struct EventRow: View {
    let event: UserTask
    let toggleCompletion: () -> Void

    var body: some View {
        HStack {
            Image(systemName: event.completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(event.completed ? .green : .gray)
                .onTapGesture {
                    toggleCompletion()
                }

            VStack(alignment: .leading) {
                Text(event.title)
                    .strikethrough(event.completed, color: .gray)
                
                // Formateamos la fecha a solo mostrar el día, mes y año
                Text(PendingTasksView().convertUTCToLocal(utcDateString: event.dueDate))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

struct PendingTasksView_Previews: PreviewProvider {
    static var previews: some View {
        PendingTasksView()
    }
}
