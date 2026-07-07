import XCTest
@testable import Vendorpay

@MainActor
final class VendorpayTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.entries = []
        store.isPro = false
    }

    func testAddEntrySucceedsUnderLimit() {
        let ok = store.add(title: "Test", amount: 10, date: Date(), note: "")
        XCTAssertTrue(ok)
        XCTAssertEqual(store.entries.count, 1)
    }

    func testAddEntryBlockedAtFreeLimit() {
        for i in 0..<Store.freeLimit {
            _ = store.add(title: "Entry \(i)", amount: 1, date: Date(), note: "")
        }
        XCTAssertEqual(store.entries.count, Store.freeLimit)
        let ok = store.add(title: "Overflow", amount: 1, date: Date(), note: "")
        XCTAssertFalse(ok)
        XCTAssertEqual(store.entries.count, Store.freeLimit)
    }

    func testProUserBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            _ = store.add(title: "Entry \(i)", amount: 1, date: Date(), note: "")
        }
        XCTAssertEqual(store.entries.count, Store.freeLimit + 5)
    }

    func testDeleteEntry() {
        _ = store.add(title: "ToDelete", amount: 5, date: Date(), note: "")
        XCTAssertEqual(store.entries.count, 1)
        store.delete(store.entries[0])
        XCTAssertEqual(store.entries.count, 0)
    }

    func testUpdateEntry() {
        _ = store.add(title: "Original", amount: 5, date: Date(), note: "")
        var entry = store.entries[0]
        entry.title = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries[0].title, "Updated")
    }

    func testTotalAmountSum() {
        _ = store.add(title: "A", amount: 5, date: Date(), note: "")
        _ = store.add(title: "B", amount: 15, date: Date(), note: "")
        XCTAssertEqual(store.totalAmount, 20, accuracy: 0.001)
    }

    func testSeedDataCountBelowFreeLimit() {
        XCTAssertLessThan(Store.seedData().count, Store.freeLimit)
    }

    func testCanAddMoreReflectsLimit() {
        XCTAssertTrue(store.canAddMore)
    }
}
