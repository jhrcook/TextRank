//
//  TextGraphTests.swift
//  textrankTests
//
//  Created by Joshua on 11/17/20.
//

@testable import TextRank
import XCTest

class TextGraphTests: XCTestCase {
    func testInitialization() {
        let startingScore: Float = 0.5
        let damping: Float = 1
        let convergenceThreshold: Float = 0.02

        let graph = TextGraph<String>(startingScore: startingScore, damping: damping, convergenceThreshold: convergenceThreshold)
        XCTAssertEqual(graph.startingScore, startingScore)
        XCTAssertEqual(graph.damping, damping)
        XCTAssertEqual(graph.convergenceThreshold, convergenceThreshold)
    }

    func testAddingEdges() {
        let graph = TextGraph<String>()

        /*
         "A" --> "B" --> "C"
          \--> D <-------/
         */

        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "B", to: "C")
        graph.addEdge(from: "C", to: "D")
        graph.addEdge(from: "A", to: "D")

        XCTAssertEqual(graph.numberOfNodes, 4)
        XCTAssertEqual(graph.numberOfEdges, 4)
        XCTAssertEqual(graph.nodesPointingTo("B"), ["A"])
        XCTAssertEqual(graph.nodesPointingTo("C"), ["B"])
        XCTAssertEqual(graph.nodesPointingTo("D"), ["C", "A"])
        XCTAssertNil(graph.graph["A"])
        XCTAssertEqual(graph.nodesPointingTo("A"), [String]())
    }

    func testPruningOfUnreachableNodes() {
        let graph = TextGraph<String>()
        graph.addEdge(from: "A", to: "B", weight: 1)
        graph.addEdge(from: "A", to: "C", weight: 0) // should NOT be added
        XCTAssertEqual(graph.edgeWeight("A", "B"), 1)
        XCTAssertEqual(graph.edgeWeight("A", "C"), 0) // no edge weight
        XCTAssertEqual(graph.edgeWeight("A", "D"), 0) // no edge weight
        XCTAssertNil(graph.nodes["C"]) // should not find node "C"
    }

    func testDataAccessingFunctions() {
        let graph = TextGraph<String>()

        // One edge: A -> B
        graph.addEdge(from: "A", to: "B")
        XCTAssertEqual(graph.edgeWeight("A", "B"), 1.0)
        // Change edge weight: A -> B
        graph.addEdge(from: "A", to: "B", weight: 2.0)
        XCTAssertEqual(graph.edgeWeight("A", "B"), 2.0)
        XCTAssertEqual(graph.totalEdgeWeightFrom("A"), 2.0)
        XCTAssertEqual(graph.totalEdgeWeightFrom("B"), 0.0)
        XCTAssertEqual(graph.edgeWeight("B", "A"), 0.0)
        XCTAssertEqual(graph.numberOfLinksFrom("A"), 1)
        XCTAssertEqual(graph.nodesPointingTo("B"), ["A"])

        // Two edges: A -> C
        graph.addEdge(from: "A", to: "C", weight: 5.5)
        XCTAssertEqual(graph.edgeWeight("A", "B"), 2.0)
        XCTAssertEqual(graph.edgeWeight("A", "C"), 5.5)
        XCTAssertEqual(graph.totalEdgeWeightFrom("A"), 7.5)
        XCTAssertEqual(graph.numberOfLinksFrom("A"), 2)

        // Third edge pointing back from C -> A with different weight.
        graph.addEdge(from: "C", to: "A", weight: 0.1)
        XCTAssertEqual(graph.edgeWeight("A", "C"), 5.5)
        XCTAssertEqual(graph.edgeWeight("C", "A"), 0.1)
        XCTAssertEqual(graph.totalEdgeWeightFrom("A"), 7.5)
        XCTAssertEqual(graph.numberOfLinksFrom("A"), 2)
    }

    static var allTests = [
        ("testInitialization", testInitialization),
        ("testAddingEdges", testAddingEdges),
        ("testPruningOfUnreachableNodes", testPruningOfUnreachableNodes),
        ("testDataAccessingFunctions", testDataAccessingFunctions),
    ]
}
