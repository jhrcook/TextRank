@testable import TextRank
import XCTest

class SentenceTests: XCTestCase {
    func testInitialization() {
        var sentence = Sentence(text: "word")
        XCTAssertEqual(sentence.text, "word")
        XCTAssertEqual(sentence.allWords, ["word"])
    }

    func testCleaning() {
        let testCleaningCases: [String: [String]] = [
            "simple case with nothing fancy": ["simple", "case", "with", "nothing", "fancy"],
            "Some Capital LetTers ALL oveR ThE plaCE": ["some", "capital", "letters", "all", "over", "the", "place"],
            "some - punc.tuation /|\\ #$ and even, more) pretty !@,. random?": ["some", "punc", "tuation", "and", "even", "more", "pretty", "random"],
        ]
        for (original, clean) in testCleaningCases {
            var s = Sentence(text: original)
            XCTAssertEqual(s.allWords, clean)
        }
    }
}
