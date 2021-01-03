@testable import TextRank
import XCTest

class SentenceTests: XCTestCase {
    func testInitialization() {
        let sentence = Sentence(text: "word")
        XCTAssertEqual(sentence.text, "word")
        XCTAssertEqual(sentence.words, Set(["word"]))
    }

    func testCleaning() {
        let testCleaningCases: [String: [String]] = [
            "simple case with nothing fancy": ["simple", "case", "fancy"],
            "Some Capital LetTers ALL oveR ThE plaCE": ["capital", "letters", "place"],
            "some - punc.tuation /|\\ #$ and even, more) pretty !@,. random?": ["punc", "tuation", "pretty", "random"],
        ]
        for (original, clean) in testCleaningCases {
            let s = Sentence(text: original)
            XCTAssertEqual(s.words, Set(clean))
        }
    }
}
