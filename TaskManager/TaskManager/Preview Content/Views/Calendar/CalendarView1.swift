import SwiftUI

struct Event: Identifiable, Codable {
    let id: Int
    var name: String
    var date: String
    var time: String
    var description: String
    var color: Int
    let usuario: UserReference

    struct UserReference: Codable {
        let id: Int
    }

    var dateValue: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
}


class EventService1: ObservableObject {
    let baseUrl = "http://localhost:8080/eventos/user_id"
    // El userId se obtiene dinámicamente desde UserSession

    @EnvironmentObject var userSession: UserSession // Solo funciona en View, así que pasaremos userId como parámetro

    func fetchEvents(for userId: Int, completion: @escaping ([Event]) -> Void) {
        guard let url = URL(string: "\(baseUrl)/\(userId)") else {
            print("URL inválida")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([Event].self, from: data)
                    DispatchQueue.main.async {
                        completion(decoded)
                    }
                } catch {
                    print("Error al decodificar eventos: \(error)")
                }
            } else if let error = error {
                print("Error al obtener eventos: \(error)")
            }
        }.resume()
    }
    
    func updateEvent(_ event: Event, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:8080/eventos/\(event.id)") else {
            print("URL inválida para actualización")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(event)
            request.httpBody = jsonData
        } catch {
            print("Error codificando evento: \(error)")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la actualización: \(error)")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(true)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
}

struct WeeklyCalendarView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession

    @State private var selectedDate = Date()
    @State private var currentWeek: [Date] = []
    @State private var allEvents: [Event] = []
    @State private var selectedEvent: Event? = nil
    let eventService1 = EventService1()

    var eventsForSelectedDate: [Event] {
        allEvents.filter {
            if let eventDate = $0.dateValue {
                return Calendar.current.isDate(eventDate, inSameDayAs: selectedDate)
            }
            return false
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Spacer()
                Text(weekRange())
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding()
            
            HStack(spacing: 10) {
                ForEach(currentWeek, id: \.self) { day in
                    VStack {
                        Text(dayOfWeekFormatter.string(from: day))
                            .font(.caption)
                        Text(dayNumberFormatter.string(from: day))
                            .font(.headline)
                            .padding(8)
                            .background(Calendar.current.isDate(day, inSameDayAs: selectedDate) ? Color.blue : Color.clear)
                            .clipShape(Circle())
                            .foregroundColor(Calendar.current.isDate(day, inSameDayAs: selectedDate) ? .white : .black)
                    }
                    .onTapGesture {
                        selectedDate = day
                        print("Selected date: \(selectedDate)")
                    }
                }
            }
            .padding()
            
            List {
                if eventsForSelectedDate.isEmpty {
                    Text("No hay eventos para esta fecha").foregroundColor(.gray)
                } else {
                    ForEach(eventsForSelectedDate) { event in
                        HStack {
                            Circle()
                                .fill(colorForPriority(event.color))
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading) {
                                Text(event.time)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(event.name)
                                    .font(.headline)
                            }
                        }
                        .onTapGesture {
                            selectedEvent = event
                        }
                    }
                }
            }
        }
        .onAppear {
            generateCurrentWeek()
            // Solo buscar eventos si hay userId disponible
            if let userId = userSession.userId {
                eventService1.fetchEvents(for: userId) { fetched in
                    self.allEvents = fetched
                }
            } else {
                print("Usuario no encontrado")
            }
        }
        .navigationBarBackButtonHidden(true) // Ocultar el botón de regreso por defecto
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: binding(for: event))
        }
    }
    
    private func binding(for event: Event) -> Binding<Event> {
        guard let index = allEvents.firstIndex(where: { $0.id == event.id }) else {
            fatalError("Evento no encontrado")
        }
        return $allEvents[index]
    }
    
    private func generateCurrentWeek() {
        let calendar = Calendar.current
        if let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start {
            currentWeek = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        } else {
            currentWeek = [] // Evita crasheos si no se puede calcular la semana
        }
    }
    
    private func previousWeek() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!
        generateCurrentWeek()
        print("Previous week: \(currentWeek)")
    }
    
    private func nextWeek() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate)!
        generateCurrentWeek()
        print("Next week: \(currentWeek)")
    }
    
    private func weekRange() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        
        guard let firstDay = currentWeek.first, let lastDay = currentWeek.last else {
            return "Semana desconocida"
        }
        
        let start = formatter.string(from: firstDay)
        let end = formatter.string(from: lastDay)
        return "\(start) - \(end)"
    }
    
    private var dayOfWeekFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var dayNumberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    private func colorForPriority(_ color: Int) -> Color {
        switch color {
        case 1: return .red
        case 2: return .yellow
        case 3: return .green
        default: return .gray
        }
    }
}

struct WeeklyCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCalendarView().environmentObject(UserSession())
    }
}

struct EventDetailView: View {
    @Environment(\.presentationMode) var presentationMode

    @Binding var event: Event

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Evento")) {
                    TextField("Nombre", text: $event.name)
                    TextField("Descripción", text: $event.description)
                    TextField("Hora", text: $event.time)
                }

                Section(header: Text("Color")) {
                    Picker("Prioridad", selection: $event.color) {
                        Text("Rojo").tag(1)
                        Text("Amarillo").tag(2)
                        Text("Verde").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarTitle("Editar Evento", displayMode: .inline)
            .navigationBarItems(trailing: Button("Guardar") {
                let service = EventService1()
                service.updateEvent(event) { success in
                    if success {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("❌ Error al actualizar el evento.")
                    }
                }
            })
        }
    }
}
