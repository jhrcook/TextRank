//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

class TextRank {
    public var text: String {
        didSet {
            sentences = TextRank.splitIntoSentences(text)
        }
    }

    public var summarizationFraction: Float = 0.2
    public var graph: TextGraph
    public var graphDamping: Float = 0.85

    public var sentences = [Sentence]()

    public init(text: String) {
        self.text = text
        sentences = TextRank.splitIntoSentences(text)
        graph = TextGraph()
    }

    public init(text: String, summarizationFraction: Float = 0.2, graphDamping: Float = 0.85) {
        self.text = text
        sentences = TextRank.splitIntoSentences(text)
        self.summarizationFraction = summarizationFraction
        self.graphDamping = graphDamping
        graph = TextGraph()
    }
}

extension TextRank {
    func similarity(_ a: inout Sentence, _ b: inout Sentence) -> Float {
        if a.words.count == 0 || b.words.count == 0 { return 0.0 }
        let commonWordCount = Float(a.words.intersection(b.words).count)
        let totalWordCount = log10(Float(a.words.count)) + log10(Float(b.words.count))
        return totalWordCount == 0.0 ? 0.0 : commonWordCount / totalWordCount
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
