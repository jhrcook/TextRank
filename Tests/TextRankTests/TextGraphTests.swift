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

    static var allTests = [
        ("testInitialization", testInitialization),
        ("testAddingEdges", testAddingEdges),
    ]
}
