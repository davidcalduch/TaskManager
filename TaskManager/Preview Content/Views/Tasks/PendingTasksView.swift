//  PendingTasksView.swift
//  TaskManager
//
//  Created by David Calduch on 2/1/25.
//

import SwiftUI

struct PendingTasksView: View {
    @State private var tasks: [Task] = [
        Task(title: "Comprar leche", date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!, completed: false),
        Task(title: "Estudiar Swift", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, completed: false),
        Task(title: "Terminar backend", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, completed: false),
        Task(title: "Ir al gimnasio", date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, completed: false)
    ]

    private var groupedTasks: [String: [Task]] {
        Dictionary(grouping: tasks.filter { !$0.completed }) { task in
            return dayOfWeekFormatter.string(from: task.date)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedTasks.keys.sorted(), id: \.self) { day in
                    Section(header: Text(day).font(.headline)) {
                        ForEach(groupedTasks[day]!) { task in
                            TaskRow(task: task, toggleCompletion: toggleTaskCompletion)
                        }
                    }
                }
            }
            .navigationTitle("Pending Tasks")
        }
    }

    private func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].completed.toggle()
        }
    }

    private var dayOfWeekFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
}

struct TaskRow: View {
    let task: Task
    var toggleCompletion: (Task) -> Void

    var body: some View {
        HStack {
            Button(action: {
                toggleCompletion(task)
            }) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.completed ? .green : .gray)
            }
            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.completed, color: .gray)
                Text(dateFormatter.string(from: task.date))
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

