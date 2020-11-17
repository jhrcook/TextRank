//
//  TextGraphTests.swift
//  textrankTests
//
//  Created by Joshua on 11/17/20.
//

@testable import textrank
import XCTest

class TextGraphTests: XCTestCase {
    func testInitialization() {
        let startingScore: Float = 0.5
        let damping: Float = 1
        let convergence: Float = 0.001

        let graph = TextGraph<String>(startingScore: startingScore, damping: damping, convergence: convergence)
        XCTAssertEqual(graph.startingScore, startingScore)
        XCTAssertEqual(graph.damping, damping)
        XCTAssertEqual(graph.convergence, convergence)
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
        XCTAssertEqual(graph.graph["A"], ["B", "D"])
        XCTAssertEqual(graph.graph["C"], ["D"])
        XCTAssertEqual(graph.graph["D"], nil)
    }

    static var allTests = [
        ("testInitialization", testInitialization),
        ("testAddingEdges", testAddingEdges),
    ]
}
