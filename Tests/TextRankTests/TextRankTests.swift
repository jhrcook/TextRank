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
        var sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 4.0 / (log10(4.0) + log10(4.0)))

        s1 = Sentence(text: "dog bear sheep lion")
        s2 = Sentence(text: "dog bear sheep")
        sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 3.0 / (log10(4.0) + log10(3.0)))

        s1 = Sentence(text: "dog bear sheep lion to there")
        s2 = Sentence(text: "dog bear sheep we them")
        sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 3.0 / (log10(4.0) + log10(3.0)))

        s1 = Sentence(text: "")
        s2 = Sentence(text: "dog bear sheep we them")
        sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 0.0)

        s1 = Sentence(text: "there will")
        s2 = Sentence(text: "dog bear sheep we them")
        sim = textRank.similarity(s1, s2)
        XCTAssertEqual(sim, 0.0)

        s1 = Sentence(text: "fox peacock there will")
        s2 = Sentence(text: "dog bear sheep we them")
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
}
