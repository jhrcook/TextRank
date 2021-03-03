@testable import TextRank
import XCTest

class SentenceTests: XCTestCase {
    func testInitialization() {
        let sentence = Sentence(text: "word", originalTextIndex: 0)
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
            let s = Sentence(text: original, originalTextIndex: 0)
            XCTAssertEqual(s.words, Set(clean))
        }
    }

    func testRemovalOfStopWords() {
        // Given
        let text = "here are some words to be"

        // When
        let sentence = Sentence(text: text, originalTextIndex: 0)

        // Then
        XCTAssertEqual(sentence.length, 0)
    }

    func testRemovalOfStopWordsButNotMeaningfulWords() {
        // Given
        let text = "here are some words to be lion"

        // When
        let sentence = Sentence(text: text, originalTextIndex: 0)

        // Then
        XCTAssertEqual(sentence.length, 1)
        XCTAssertEqual(sentence.words, Set(["lion"]))
    }

    func testRemovalOfStopWordsAndAdditionalStopwords() {
        // Given
        let text = "here are some words to be lion"

        // When
        let sentence = Sentence(text: text, originalTextIndex: 0, additionalStopwords: ["lion"])

        // Then
        XCTAssertEqual(sentence.length, 0)
    }
}
