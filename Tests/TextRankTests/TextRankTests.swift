@testable import TextRank
import XCTest

class TextRankTests: XCTestCase {
    func testInitialization() {
        let textRank = TextRank(text: "Here is some text. There are two sentences.")
        XCTAssertEqual(textRank.sentences.count, 2)
    }

    func testComparingSentences() {
        let textRank = TextRank(text: "")

        var s1 = Sentence(text: "dog bear sheep lion")
        var s2 = Sentence(text: "dog bear sheep lion")
        var sim = textRank.similarity(&s1, &s2)
        XCTAssertEqual(sim, 4.0 / (log10(4.0) + log10(4.0)))

        s1 = Sentence(text: "dog bear sheep lion")
        s2 = Sentence(text: "dog bear sheep")
        sim = textRank.similarity(&s1, &s2)
        XCTAssertEqual(sim, 3.0 / (log10(4.0) + log10(3.0)))

        s1 = Sentence(text: "dog bear sheep lion to there")
        s2 = Sentence(text: "dog bear sheep we them")
        sim = textRank.similarity(&s1, &s2)
        XCTAssertEqual(sim, 3.0 / (log10(4.0) + log10(3.0)))

        s1 = Sentence(text: "")
        s2 = Sentence(text: "dog bear sheep we them")
        sim = textRank.similarity(&s1, &s2)
        XCTAssertEqual(sim, 0.0)

        s1 = Sentence(text: "there will")
        s2 = Sentence(text: "dog bear sheep we them")
        sim = textRank.similarity(&s1, &s2)
        XCTAssertEqual(sim, 0.0)

        s1 = Sentence(text: "fox peacock there will")
        s2 = Sentence(text: "dog bear sheep we them")
        sim = textRank.similarity(&s1, &s2)
        XCTAssertEqual(sim, 0.0)
    }
}
