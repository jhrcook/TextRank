//
//  PageRankTests.swift
//  textrankTests
//
//  Created by Joshua on 11/17/20.
//

@testable import TextRank
import XCTest

class PageRankTests: XCTestCase {
    func testSimplePageRank() {
        let graph = TextGraph<String>()

        /*
         "A" --> "B" --> "C"
         */

        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "B", to: "C")
        var pageRankResult: TextGraph<String>.PageRankResult?
        do {
            pageRankResult = try? graph.executePageRank()
        }

        XCTAssertNotNil(pageRankResult)
        XCTAssertTrue(pageRankResult!.didFinishSuccessfully)
        XCTAssertEqual(graph.numberOfNodes, 3)
        XCTAssertEqual(graph.numberOfEdges, 2)
        XCTAssertGreaterThan(graph.nodes["B"]!, graph.nodes["A"]!)
        XCTAssertGreaterThan(graph.nodes["C"]!, graph.nodes["B"]!)
    }

    func testEffectOfEdgeWeightsOnPageRank() {
        let graph = TextGraph<String>()

        /*
         "A" -> "B"   w: 1
         "A" -> "C"   w: 0.5
         */

        graph.addEdge(from: "A", to: "B", weight: 10.0)
        graph.addEdge(from: "A", to: "C", weight: 0.5)

        var pageRankResult: TextGraph<String>.PageRankResult?
        do {
            pageRankResult = try? graph.executePageRank()
        }

        XCTAssertNotNil(pageRankResult)
        XCTAssertTrue(pageRankResult!.didFinishSuccessfully)
        XCTAssertGreaterThan(graph.nodes["B"]!, graph.nodes["A"]!)
        XCTAssertGreaterThan(graph.nodes["C"]!, graph.nodes["A"]!)
        XCTAssertGreaterThan(graph.nodes["B"]!, graph.nodes["C"]!)
    }

    static var allTests = [
        ("testSimplePageRank", testSimplePageRank),
        ("testEffectOfEdgeWeightsOnPageRank", testEffectOfEdgeWeightsOnPageRank),
    ]
}
