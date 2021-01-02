@testable import TextRank
import XCTest

class TextGraphTests: XCTestCase {
    func testInitialization() {
        let graph = TextGraph()
        XCTAssertTrue(graph.damping >= 0 && graph.damping <= 1)
        XCTAssertTrue(graph.nodes.count == 0)
        XCTAssertTrue(graph.edgeWeights.count == 0)
        XCTAssertTrue(graph.connectingEdgeCounts.count == 0)

        let graph2 = TextGraph(damping: 0.2)
        XCTAssertTrue(graph2.damping == 0.2)
    }

    func testAddingEdges() {
        let graph = TextGraph()
        let nodeA = Sentence(text: "node a")
        let nodeB = Sentence(text: "node b")
        // Add edge between two nodes.
        graph.addEdge(from: nodeA, to: nodeB)

        // Check sizes of graph attributes.
        XCTAssertTrue(graph.nodes.count == 2)
        XCTAssertTrue(graph.edgeWeights.count == 1)
        XCTAssertTrue(graph.connectingEdgeCounts.count == 2)

        // Check expected values of edge weights and node values.
        XCTAssertEqual(graph.getEdgeWeight(from: nodeA, to: nodeB), 1.0)
        XCTAssertEqual(graph.getValue(of: nodeA), 1.0)
        XCTAssertEqual(graph.getValue(of: nodeB), 1.0)
        XCTAssertEqual(graph.getNumberOfEdges(from: nodeA), 1)
        XCTAssertEqual(graph.getNumberOfEdges(from: nodeB), 1)

        // Adding the same edge should not have any effect.
        graph.addEdge(from: nodeA, to: nodeB)
        XCTAssertTrue(graph.nodes.count == 2)
        XCTAssertTrue(graph.edgeWeights.count == 1)
        XCTAssertTrue(graph.connectingEdgeCounts.count == 2)

        // Change weight of an edge.
        graph.addEdge(from: nodeA, to: nodeB, withWeight: 2.5)
        XCTAssertEqual(graph.getEdgeWeight(from: nodeA, to: nodeB), 2.5)
    }
}
