import XCTest
@testable import textrank

final class textrankTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(textrank().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
