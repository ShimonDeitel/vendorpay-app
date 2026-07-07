import XCTest

final class VendorpayUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddEntryFlow() {
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("New Entry")
        app.textFields["amountField"].tap()
        app.textFields["amountField"].typeText("9.99")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["New Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<25 {
            app.buttons["addEntryButton"].tap()
            let titleField = app.textFields["titleField"]
            if titleField.waitForExistence(timeout: 1) {
                titleField.tap()
                titleField.typeText("Entry \(i)")
                app.textFields["amountField"].tap()
                app.textFields["amountField"].typeText("1")
                app.buttons["saveButton"].tap()
            } else {
                break
            }
        }
        XCTAssertTrue(app.buttons["purchaseButton"].waitForExistence(timeout: 3))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Dismiss Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.navigationBars.staticTexts.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.waitForExistence(timeout: 1))
    }

    func testSettingsOpens() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}
