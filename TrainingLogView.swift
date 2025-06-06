import SwiftUI

struct TrainingLog: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let part: String
    let exerciseName: String
    let weight: Double
    let reps: Int
    let sets: Int
    var volume: Double { weight * Double(reps * sets) }
}

class TrainingLogStore: ObservableObject {
    @Published var logs: [TrainingLog] = [] {
        didSet { saveLogs() }
    }

    private let userDefaultsKey = "TrainingLogs"

    init() {
        loadLogs()
    }

    func addLog(date: Date, part: String, exerciseName: String, weight: Double, reps: Int, sets: Int) {
        let log = TrainingLog(date: date, part: part, exerciseName: exerciseName, weight: weight, reps: reps, sets: sets)
        logs.append(log)
    }

    private func saveLogs() {
        guard let data = try? JSONEncoder().encode(logs) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    private func loadLogs() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let saved = try? JSONDecoder().decode([TrainingLog].self, from: data) else { return }
        logs = saved
    }
}

struct TrainingLogView: View {
    @State private var selectedPart = "胸"
    @State private var exerciseName = ""
    @State private var weightText = ""
    @State private var repsText = ""
    @State private var setsText = ""
    @ObservedObject private var store = TrainingLogStore()

    var body: some View {
        NavigationView {
            Form {
                Picker("部位", selection: $selectedPart) {
                    ForEach(["胸", "背中", "脚", "肩", "腕", "体幹"], id: \.self) { part in
                        Text(part).tag(part)
                    }
                }
                TextField("種目名", text: $exerciseName)
                TextField("重量(kg)", text: $weightText)
                    .keyboardType(.decimalPad)
                TextField("回数", text: $repsText)
                    .keyboardType(.numberPad)
                TextField("セット数", text: $setsText)
                    .keyboardType(.numberPad)
                Button("登録") {
                    addLog()
                }
            }
            .navigationTitle("トレーニング記録")
            List(store.logs) { log in
                VStack(alignment: .leading) {
                    Text("\(log.exerciseName) - \(log.part)")
                    Text("重量: \(log.weight, specifier: "%.1f")kg  回数: \(log.reps)  セット: \(log.sets)")
                    Text("ボリューム: \(log.volume, specifier: "%.1f")")
                    Text(log.date, style: .date)
                }
            }
        }
    }

    private func addLog() {
        guard let weight = Double(weightText), let reps = Int(repsText), let sets = Int(setsText) else { return }
        store.addLog(date: Date(), part: selectedPart, exerciseName: exerciseName, weight: weight, reps: reps, sets: sets)
        exerciseName = ""
        weightText = ""
        repsText = ""
        setsText = ""
    }
}

struct TrainingLogView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingLogView()
    }
}

