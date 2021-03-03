@testable import TextRank
import XCTest

class TextRankTests: XCTestCase {
    func testInitialization() {
        let textRank = TextRank(text: "Here is some text. There are two sentences.")
        XCTAssertEqual(textRank.sentences.count, 2)
    }

    func testComparingSentences() {
        let textRank = TextRank(text: "")

        var s1 = Sentence(text: "dog bear sheep lion", originalTextIndex: 0)
        var s2 = Sentence(text: "dog bear sheep lion", originalTextIndex: 1)
        var sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 4.0 / (log10(4.0) + log10(4.0)))

        s1 = Sentence(text: "dog bear sheep lion", originalTextIndex: 0)
        s2 = Sentence(text: "dog bear sheep", originalTextIndex: 1)
        sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 3.0 / (log10(4.0) + log10(3.0)))

        s1 = Sentence(text: "dog bear sheep lion to there", originalTextIndex: 0)
        s2 = Sentence(text: "dog bear sheep we them", originalTextIndex: 1)
        sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 3.0 / (log10(4.0) + log10(3.0)))

        s1 = Sentence(text: "", originalTextIndex: 0)
        s2 = Sentence(text: "dog bear sheep we them", originalTextIndex: 1)
        sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 0.0)

        s1 = Sentence(text: "there will", originalTextIndex: 0)
        s2 = Sentence(text: "dog bear sheep we them", originalTextIndex: 1)
        sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 0.0)

        s1 = Sentence(text: "fox peacock there will", originalTextIndex: 0)
        s2 = Sentence(text: "dog bear sheep we them", originalTextIndex: 1)
        sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 0.0)
    }

    func testBuildingGraph() {
        var text = "Dog cat bird. Sheep dog cat. Horse cow fish."
        let textRank = TextRank(text: text)
        textRank.buildGraph()
        XCTAssertEqual(textRank.graph.nodes.count, 2)
        XCTAssertEqual(textRank.graph.edges.count, 2)

        text = "Dog cat bird. Sheep dog cat peacock. Horse cow fish dog chicken."
        textRank.text = text
        textRank.buildGraph()
        XCTAssertEqual(textRank.graph.nodes.count, 3)
        XCTAssertEqual(textRank.graph.edges.count, 3)
        let nodes = textRank.graph.nodes.keys.sorted(by: { $0.length < $1.length })
        XCTAssertGreaterThan(
            textRank.graph.getEdgeWeight(from: nodes[0], to: nodes[1]),
            textRank.graph.getEdgeWeight(from: nodes[0], to: nodes[2])
        )
    }

    func testSimplePageRank() throws {
        let text = "Dog cat bird. Sheep dog cat. Horse cow fish. Horse cat lizard. Lizard dragon bird."
        let textRank = TextRank(text: text)
        let pageRankResults = try textRank.runPageRank()
        XCTAssertTrue(pageRankResults.didConverge)
        XCTAssertLessThan(pageRankResults.iterations, 20)
        XCTAssertEqual(pageRankResults.results.count, 5)
        print(pageRankResults.results)
        XCTAssertEqual(
            pageRankResults.results[Sentence(text: "Horse cat lizard.", originalTextIndex: 3)],
            pageRankResults.results.values.max()
        )
    }

    func testFilteringTopSentences() throws {
        // Given
        let text = "Dog cat bird. Sheep dog cat. Horse cow fish. Horse cat lizard. Lizard dragon bird."
        let textRank = TextRank(text: text)
        let results = try textRank.runPageRank()

        // When
        let filteredResults = textRank.filterTopSentencesFrom(results, top: 0.75)

        // Then
        XCTAssertTrue(filteredResults.count < results.results.count)
        XCTAssertTrue(filteredResults.count == 2)
    }

    func testStopwordsAreRemoved() {
        // Given
        let text = "Here are some sentences dog cat. With intentional stopwords gator. And some words that are not."

        // When
        let textRank = TextRank(text: text)

        // Then
        XCTAssertEqual(textRank.sentences.count, 2)
        XCTAssertEqual(textRank.sentences[0].length, 3)
        XCTAssertEqual(textRank.sentences.filter { $0.originalTextIndex == 0 }[0].words,
                       Set(["sentences", "dog", "cat"]))
        XCTAssertEqual(textRank.sentences.filter { $0.originalTextIndex == 1 }[0].words,
                       Set(["intentional", "stopwords", "gator"]))
        XCTAssertEqual(textRank.sentences[1].length, 3)
    }

    func testAdditionalStopwords() {
        // Given
        let text = "Here are some sentences dog cat. With intentional stopwords gator. And some words that are not."
        let additionalStopwords = ["dog", "gator"]

        // When
        let textRank = TextRank(text: text)
        textRank.stopwords = additionalStopwords

        // Then
        XCTAssertEqual(textRank.sentences.count, 2)
        XCTAssertEqual(textRank.sentences[0].length, 2)
        XCTAssertEqual(textRank.sentences.filter { $0.originalTextIndex == 0 }[0].words,
                       Set(["sentences", "cat"]))
        XCTAssertEqual(textRank.sentences.filter { $0.originalTextIndex == 1 }[0].words,
                       Set(["intentional", "stopwords"]))
        XCTAssertEqual(textRank.sentences[1].length, 2)
    }
}
