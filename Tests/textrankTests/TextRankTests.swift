@testable import textrank
import XCTest

final class TextRankTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TextRank(text: "Hello, World!", by: .sentence).text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
