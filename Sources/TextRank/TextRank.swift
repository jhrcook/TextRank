//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

struct TextRank {
    var text: String
    var summarizationFraction: Float = 0.2
    var graph: TextGraph
    var graphDamping: Float = 0.85

    init(text: String) {
        self.text = text
        graph = TextGraph()
    }

    init(text: String, summarizationFraction: Float = 0.2, graphDamping: Float = 0.85) {
        self.text = text
        self.summarizationFraction = summarizationFraction
        self.graphDamping = graphDamping
        graph = TextGraph()
    }
}
