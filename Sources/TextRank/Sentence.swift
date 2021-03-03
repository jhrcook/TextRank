//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

public struct Sentence: Hashable {
    public let text: String
    public let words: Set<String>
    public var length: Int {
        words.count
    }

    public let originalTextIndex: Int

    public init(text: String, originalTextIndex: Int) {
        self.text = text
        self.originalTextIndex = originalTextIndex
        words = Sentence.removeStopWords(from: Sentence.clean(self.text))
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }

    /// Clean a string.
    /// - Parameter s: Original text
    /// - Returns: The same text with leading and trailing whitespaces or punctuation removed.
    static func clean(_ s: String) -> [String] {
        return s
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
            .words
    }

    static func removeStopWords(from w: [String]) -> Set<String> {
        var wordSet = Set(w)
        wordSet.subtract(Stopwords.English)
        return wordSet
    }
}

extension Sentence: CustomStringConvertible {
    public var description: String {
        text
    }
}

// extension Sentence: Equatable {
//    static func == (lhs: Sentence, rhs: Sentence) -> Bool {
//        lhs.hashValue == rhs.hashValue
//    }
// }

extension StringProtocol {
    var words: [String] {
        split(whereSeparator: \.isLetter.negation).map { String($0) }
    }
}

extension Bool {
    var negation: Bool { !self }
}
