import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: VendorpayEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    summaryHeader
                    if store.entries.isEmpty {
                        emptyState
                    } else {
                        list
                    }
                }
            }
            .navigationTitle("Vendorpay")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditView(store: store) { entry in
                    _ = store.add(title: entry.title, amount: entry.amount, date: entry.date, note: entry.note)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditView(store: store, existing: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Total")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
            Text(store.totalAmount, format: .currency(code: "USD"))
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(Theme.textSecondary)
            Text("No entries yet")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Track invoices sent to clients and whether they've been paid.")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var list: some View {
        List {
            ForEach(store.entries) { entry in
                Button {
                    editingEntry = entry
                } label: {
                    row(for: entry)
                }
                .accessibilityIdentifier("entryRow_\(entry.title)")
                .listRowBackground(Theme.cardBackground)
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }

    private func row(for entry: VendorpayEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textPrimary)
                Text(entry.date, style: .date)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Text(entry.amount, format: .currency(code: "USD"))
                .font(Theme.bodyFont.weight(.semibold))
                .foregroundStyle(entry.isPaidOrDone ? Theme.accent : Theme.textPrimary)
        }
        .padding(.vertical, 4)
    }
}

struct EntryEditView: View {
    @ObservedObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var amountText: String
    @State private var date: Date
    @State private var note: String
    var onSave: (VendorpayEntry) -> Void

    private let existingID: UUID?

    init(store: Store, existing: VendorpayEntry? = nil, onSave: @escaping (VendorpayEntry) -> Void) {
        self.store = store
        self.onSave = onSave
        self.existingID = existing?.id
        _title = State(initialValue: existing?.title ?? "")
        _amountText = State(initialValue: existing.map { String(format: "%.2f", $0.amount) } ?? "")
        _date = State(initialValue: existing?.date ?? Date())
        _note = State(initialValue: existing?.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("titleField")
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("amountField")
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note", text: $note)
                        .accessibilityIdentifier("noteField")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(existingID == nil ? "Add Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let amount = Double(amountText) ?? 0
                        let entry = VendorpayEntry(id: existingID ?? UUID(), title: title.isEmpty ? "Untitled" : title, amount: amount, date: date, note: note)
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
