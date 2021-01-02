@testable import TextRank
import XCTest

class TextRankTests: XCTestCase {
    func testInitialization() {
        let textRank = TextRank(text: "Here is some text. There are two sentences.")
        XCTAssertEqual(textRank.sentences.count, 2)
    }
}
