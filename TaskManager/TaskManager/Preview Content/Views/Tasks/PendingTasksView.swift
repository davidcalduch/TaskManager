import SwiftUI
import Foundation

struct UserTask: Identifiable, Codable {
    var id: Int
    var title: String
    var dueDate: String
    var completed: Bool

    // Computed property to convert dueDate string to Date
    var date: Date {
        // Try to parse ISO8601 first, then fallback to other formats if needed
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dueDate) {
            return date
        }
        // Fallback: try standard DateFormatter if needed (customize as necessary)
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = fallbackFormatter.date(from: dueDate) {
            return date
        }
        // If parsing fails, return current date as fallback
        return Date()
    }
}

struct PendingTasksView: View {
    @State private var tasks: [UserTask] = []
    @State private var isLoading = true

    var groupedTasks: [String: [UserTask]] {
        Dictionary(grouping: tasks.filter { !$0.completed }) { task in
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
                                EventRow(event: task)
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
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].completed.toggle()
        }
    }

    private func fetchTasks() {
        guard let url = URL(string: "http://localhost:8080/tasks") else { return }

        // Basic Authentication credentials
        let username = "david"
        let password = "Pitita_44"
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else { return }
        let base64LoginString = loginData.base64EncodedString()

        var request = URLRequest(url: url)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let decoder = JSONDecoder()
        // No dateDecodingStrategy needed, dueDate is String

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
                if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                    print("Respuesta del servidor: \(errorBody)")
                }
                return
            }
            guard httpResponse.statusCode == 200 else {
                print("❌ Error HTTP: \(httpResponse.statusCode)")
                if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                    print("Respuesta del servidor: \(errorBody)")
                }
                return
            }
            if let data = data {
                do {
                    let decoded = try decoder.decode([UserTask].self, from: data)
                    print("✅ Datos recibidos y decodificados correctamente: \(decoded)")
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
}

struct EventRow: View {
    let event: UserTask

    var body: some View {
        HStack {
            Image(systemName: event.completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(event.completed ? .green : .gray)

            VStack(alignment: .leading) {
                Text(event.title)
                    .strikethrough(event.completed, color: .gray)
                Text(dateFormatter.string(from: event.date))
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
