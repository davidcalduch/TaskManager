import SwiftUI
import UIKit

struct WeeklyCalendarView: UIViewRepresentable {
    var didSelectDay: (String) -> Void
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.itemSize = CGSize(width: 80, height: 100)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(didSelectDay: didSelectDay)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        var didSelectDay: (String) -> Void
        
        init(didSelectDay: @escaping (String) -> Void) {
            self.didSelectDay = didSelectDay
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return daysOfWeek.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CalendarCell
            cell.label.text = daysOfWeek[indexPath.item]
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            didSelectDay(daysOfWeek[indexPath.item])
        }
    }
}

class CalendarCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue
        label.textAlignment = .center
        label.textColor = .white
        label.frame = contentView.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct DayDetailView: View {
    var day: String
    
    var body: some View {
        VStack {
            Text("Schedule for \(day)")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle(day)
    }
}

struct ContentView: View {
    @State private var selectedDay: String? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Weekly Calendar").font(.largeTitle).padding()
                WeeklyCalendarView { day in
                    selectedDay = day
                }
                .frame(height: 120)
                .background(
                    NavigationLink(destination: DayDetailView(day: selectedDay ?? ""), isActive: Binding(
                        get: { selectedDay != nil },
                        set: { if !$0 { selectedDay = nil } }
                    )) {
                        EmptyView()
                    }
                    .hidden()
                )
            }
        }
    }
}



