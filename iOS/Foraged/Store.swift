import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [FindEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 23

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("foraged_entries.json")
    }()

    init() {
        load()
        if entries.isEmpty {
            seed()
        }
    }

    func seed() {
        entries = [
        FindEntry(name: "Chanterelles", location: "North ridge oak grove", quantity: "1.5 lb", season: "Fall", idNotes: "Gilled false, ridges true, apricot smell"),
        FindEntry(name: "Wild Blackberries", location: "Fence line by creek", quantity: "2 quarts", season: "Summer", idNotes: "Ripe, deep black, easy pull"),
        FindEntry(name: "Ramps", location: "Shaded hillside near spring", quantity: "1 bunch", season: "Spring", idNotes: "Garlic smell confirmed")
        ]
        save()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(location: String, quantity: String, season: String, idNotes: String) {
        guard canAddMore else { return }
        let entry = FindEntry(name: name, location: location, quantity: quantity, season: season, idNotes: idNotes)
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: FindEntry) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: FindEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([FindEntry].self, from: data) {
            entries = decoded
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
