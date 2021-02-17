//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

public class TextRank {
    public var text: String {
        didSet {
            sentences = TextRank.splitIntoSentences(text).filter { $0.length > 0 }
        }
    }

    public var summarizationFraction: Float = 0.2
    public var graph: TextGraph
    public var graphDamping: Float = 0.85
    public var sentences = [Sentence]()

    public init() {
        text = ""
        graph = TextGraph(damping: graphDamping)
    }

    public init(text: String) {
        self.text = text
        graph = TextGraph(damping: graphDamping)
    }

    public init(text: String, summarizationFraction: Float = 0.2, graphDamping: Float = 0.85) {
        self.text = text
        self.summarizationFraction = summarizationFraction
        self.graphDamping = graphDamping
        graph = TextGraph(damping: graphDamping)
    }
}

extension TextRank {
    public func runPageRank() throws -> TextGraph.PageRankResult {
        buildGraph()
        return try graph.runPageRank()
    }

    /// Build the TextGraph using the sentences as nodes.
    func buildGraph() {
        graph.clearGraph()
        var numberOfErrors = 0
        for (i, s1) in sentences.enumerated() {
            for s2 in sentences[(i + 1) ..< sentences.count] {
                do {
                    try graph.addEdge(from: s1, to: s2, withWeight: similarity(s1, s2))
                } catch {
                    numberOfErrors += 1
                }
            }
        }
    }

    /// Calculate the similarity of two senntences.
    /// - Parameters:
    ///   - a: First sentence.
    ///   - b: Second sentence.
    /// - Returns: Returns a float for how simillar the two sentences are. The larger the greater
    ///   simillarity, the greater the value. Zero is the minimum value.
    func similarity(_ a: Sentence, _ b: Sentence) -> Float {
        if a.words.count == 0 || b.words.count == 0 { return 0.0 }
        let commonWordCount = Float(a.words.intersection(b.words).count)
        let totalWordCount = log10(Float(a.words.count)) + log10(Float(b.words.count))
        return totalWordCount == 0.0 ? 0.0 : commonWordCount / totalWordCount
    }
}

extension TextRank {
    /// Split text into sentences.
    /// - Parameter text: Original text.
    /// - Returns: An array of sentences.
    static func splitIntoSentences(_ text: String) -> [Sentence] {
        if text.isEmpty { return [] }

        var x = [Sentence]()
        text.enumerateSubstrings(in: text.range(of: text)!, options: [.bySentences, .localized]) { substring, _, _, _ in
            if let substring = substring, !substring.isEmpty {
                x.append(Sentence(text: substring.trimmingCharacters(in: .whitespacesAndNewlines)))
            }
        }
        return Array(Set(x))
    }
}
