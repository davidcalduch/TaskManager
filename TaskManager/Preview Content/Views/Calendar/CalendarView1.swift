import SwiftUI

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let hour: String
}

struct WeeklyCalendarView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedDate = Date()
    @State private var currentWeek: [Date] = []
    @State private var events: [Event] = [
        Event(title: "Reunión de equipo", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, hour: "10:00 AM"),
        Event(title: "Entrega de proyecto", date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, hour: "3:00 PM"),
        Event(title: "Cena con amigos", date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, hour: "8:00 PM")
    ]
    
    var eventsForSelectedDate: [Event] {
        events.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
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
                            Text(event.hour)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(event.title)
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .onAppear {
            generateCurrentWeek()
            print("Current week: \(currentWeek)")
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
}

struct WeeklyCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCalendarView()
    }
}

