@testable import TextRank
import XCTest

class TextGraphTests: XCTestCase {
    func testInitialization() {
        let graph = TextGraph()
        XCTAssertTrue(graph.damping >= 0 && graph.damping <= 1)
        XCTAssertEqual(graph.nodes.count, 0)
        XCTAssertEqual(graph.edges.count, 0)

        let graph2 = TextGraph(damping: 0.2)
        XCTAssertTrue(graph2.damping == 0.2)
    }

    func testAddingOneEdge() {
        let graph = TextGraph()
        let nodeA = Sentence(text: "node a")
        let nodeB = Sentence(text: "node b")
        // Add edge between two nodes.
        try? graph.addEdge(from: nodeA, to: nodeB)

        // Check sizes of graph attributes.
        XCTAssertEqual(graph.nodes.count, 2)
        XCTAssertEqual(graph.edges.count, 2)

        // Check expected values of edge weights and node values.
        XCTAssertEqual(graph.getEdgeWeight(from: nodeA, to: nodeB), 1.0)
        XCTAssertEqual(graph.getValue(of: nodeA), 1.0)
        XCTAssertEqual(graph.getValue(of: nodeB), 1.0)
        XCTAssertEqual(graph.getTotalEdgeWeight(of: nodeA), 1.0)
        XCTAssertEqual(graph.getTotalEdgeWeight(of: nodeB), 1.0)

        // Adding the same edge should not have any effect.
        try? graph.addEdge(from: nodeA, to: nodeB)
        XCTAssertEqual(graph.nodes.count, 2)
        XCTAssertEqual(graph.edges.count, 2)

        // Change weight of an edge.
        try? graph.addEdge(from: nodeA, to: nodeB, withWeight: 2.5)
        XCTAssertEqual(graph.getEdgeWeight(from: nodeA, to: nodeB), 2.5)

        // Adding an edge with negative weight should throw an error.
        XCTAssertThrowsError(try graph.addEdge(from: nodeA, to: nodeB, withWeight: -1.0))
    }

    func testAddingMultipleEdges() {
        let graph = TextGraph()
        let nodes = ["A", "B", "C", "D"].map { Sentence(text: $0) }

        // Add an edge from [A] to all others.
        for node in nodes[1 ..< nodes.count] {
            try? graph.addEdge(from: nodes[0], to: node)
        }

        XCTAssertEqual(graph.nodes.count, nodes.count)
        XCTAssertEqual(graph.edges.count, nodes.count)
        XCTAssertEqual(graph.getTotalEdgeWeight(of: nodes[0]), 3.0)
        XCTAssertEqual(graph.getNumberOfEdges(from: nodes[0]), 3)
        XCTAssertEqual(graph.getEdgeWeight(from: nodes[0], to: nodes[1]), 1.0)

        // Add edge: [B]--[C]
        try? graph.addEdge(from: nodes[1], to: nodes[2], withWeight: 2.0)
        XCTAssertEqual(graph.nodes.count, nodes.count)
        XCTAssertEqual(graph.edges.count, 4)
        XCTAssertEqual(graph.getEdgeWeight(from: nodes[1], to: nodes[2]), 2.0)
        XCTAssertEqual(graph.getNumberOfEdges(from: nodes[1]), 2)
    }

    func testSinglePageRankIteration() {
        let graph = TextGraph()
        let nodes = ["A", "B", "C", "D"].map { Sentence(text: $0) }

        // Add an edge from [A] to all others.
        for node in nodes[1 ..< nodes.count] {
            try? graph.addEdge(from: nodes[0], to: node)
        }

        // Initialize node values.
        graph.setInitialNodeValues()
        XCTAssertTrue(graph.nodes[nodes[0]]! == 0.25)

        // Perform one iteration of the PageRank algorithm.
        let nextNodes = graph.runRoundOfPageRank(with: graph.nodes)

        XCTAssertEqual(nextNodes[nodes[0]]!, nextNodes.values.max())
        XCTAssertEqual(nextNodes[nodes[1]]!, nextNodes[nodes[2]]!)
        XCTAssertEqual(nextNodes[nodes[1]]!, nextNodes[nodes[3]]!)
    }

    func testSimplePageRank() {
        let graph = TextGraph()

        // Running PageRank with no edges or nodes should throw an error.
        XCTAssertThrowsError(try graph.runPageRank())

        // Add an edge from [A] to all others.
        let nodes = ["A", "B", "C", "D"].map { Sentence(text: $0) }
        for node in nodes[1 ..< nodes.count] {
            try? graph.addEdge(from: nodes[0], to: node)
        }

        // Run PageRank.
        let rankedSentences = try! graph.runPageRank()

        XCTAssertTrue(rankedSentences.didConverge)
        XCTAssertLessThan(rankedSentences.iterations, 100)
        XCTAssertGreaterThan(rankedSentences.iterations, 2)
        XCTAssertEqual(rankedSentences.results[nodes[0]]!, rankedSentences.results.values.max())
        XCTAssertEqual(rankedSentences.results[nodes[1]]!, rankedSentences.results[nodes[2]]!)
        XCTAssertEqual(rankedSentences.results[nodes[1]]!, rankedSentences.results[nodes[3]]!)
    }
}
