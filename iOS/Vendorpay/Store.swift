import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [VendorpayEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 20

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Vendorpay", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("entries.json")
        load()
        if entries.isEmpty {
            entries = Self.seedData()
            save()
        }
    }

    static func seedData() -> [VendorpayEntry] {
        let now = Date()
        let cal = Calendar.current
        return [
            VendorpayEntry(title: "Invoice 1", amount: 12.50, date: cal.date(byAdding: .day, value: -14, to: now) ?? now, note: "Sample entry"),
            VendorpayEntry(title: "Invoice 2", amount: 24.00, date: cal.date(byAdding: .day, value: -6, to: now) ?? now, note: "Sample entry"),
            VendorpayEntry(title: "Invoice 3", amount: 8.75, date: cal.date(byAdding: .day, value: -2, to: now) ?? now, note: "Sample entry", isPaidOrDone: true)
        ]
    }

    var canAddMore: Bool {
        isPro || entries.count < Self.freeLimit
    }

    var totalAmount: Double {
        entries.reduce(0) { $0 + $1.amount }
    }

    @discardableResult
    func add(title: String, amount: Double, date: Date, note: String) -> Bool {
        guard canAddMore else { return false }
        let entry = VendorpayEntry(title: title, amount: amount, date: date, note: note)
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: VendorpayEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: VendorpayEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([VendorpayEntry].self, from: data) {
            entries = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
