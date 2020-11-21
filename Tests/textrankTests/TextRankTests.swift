@testable import textrank
import XCTest

final class TextRankTests: XCTestCase {
    func testBuildSimpleTextRank() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TextRank("Hello, World!", by: .sentence).text, "Hello, World!")
    }

    func testSummarizationMethods() {
        let text = """
            Welcome to the Swift community. Together we are working to build a programming language to empower everyone to turn their ideas into apps on any platform.

            Announced in 2014, the Swift programming language has quickly become one of the fastest growing languages in history. Swift makes it easy to write software that is incredibly fast and safe by design. Our goals for Swift are ambitious: we want to make programming simple things easy, and difficult things possible.

            For students, learning Swift has been a great introduction to modern programming concepts and best practices. And because it is open, their Swift skills will be able to be applied to an even broader range of platforms, from mobile devices to the desktop to the cloud.
        """

        let textrank = TextRank(text, by: .sentence)

        textrank.buildSplitTextMapping()

        for (key, value) in textrank.splitText {
            XCTAssertTrue(key == key.lowercased())
            XCTAssertTrue(key == key.trimmingCharacters(in: .whitespacesAndNewlines))
            XCTAssertTrue(key == key.trimmingCharacters(in: .punctuationCharacters))
            XCTAssertTrue(value.count > 0)
        }

        textrank.buildGraph()

        for string in textrank.splitText.keys {
            XCTAssertTrue(textrank.textGraph.nodes.keys.contains(string))
        }
    }

    static var allTests = [
        ("testBuildSimpleTextRank", testBuildSimpleTextRank),
        ("testSummarizationMethods", testSummarizationMethods),
    ]
}
