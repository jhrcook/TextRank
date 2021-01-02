//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

struct TextRank {
    var text: String {
        didSet {
            sentences = TextRank.splitIntoSentences(text)
        }
    }

    var summarizationFraction: Float = 0.2
    var graph: TextGraph
    var graphDamping: Float = 0.85

    var sentences = [Sentence]()

    init(text: String) {
        self.text = text
        sentences = TextRank.splitIntoSentences(text)
        graph = TextGraph()
    }

    init(text: String, summarizationFraction: Float = 0.2, graphDamping: Float = 0.85) {
        self.text = text
        sentences = TextRank.splitIntoSentences(text)
        self.summarizationFraction = summarizationFraction
        self.graphDamping = graphDamping
        graph = TextGraph()
    }
}

extension TextRank {
    static func splitIntoSentences(_ text: String) -> [Sentence] {
        if text.isEmpty { return [] }

        var x = [Sentence]()
        text.enumerateSubstrings(in: text.range(of: text)!, options: [.bySentences, .localized]) { substring, _, _, _ in
            if let substring = substring, !substring.isEmpty {
                x.append(Sentence(text: substring))
            }
        }
        return Array(Set(x))
    }
}
