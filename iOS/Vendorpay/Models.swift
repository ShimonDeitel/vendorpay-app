import Foundation

struct VendorpayEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var amount: Double
    var date: Date
    var note: String
    var isPaidOrDone: Bool

    init(id: UUID = UUID(), title: String, amount: Double, date: Date = Date(), note: String = "", isPaidOrDone: Bool = false) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.note = note
        self.isPaidOrDone = isPaidOrDone
    }
}
