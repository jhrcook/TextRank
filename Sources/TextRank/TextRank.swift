//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

struct TextRank {
    var text: String
    var summarizationFraction: Float
    var graph: TextGraph

    init(text: String, summarizationFraction: Float = 0.20) {
        self.text = text
        self.summarizationFraction = summarizationFraction
        graph = TextGraph()
    }
}
