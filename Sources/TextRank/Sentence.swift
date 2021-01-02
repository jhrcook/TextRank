//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

struct Sentence: Hashable {
    let text: String
    var words: [String]

    init(text: String) {
        self.text = text
        words = Sentence.clean(text)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }

    static func clean(_ s: String) -> [String] {
        return s
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
            .words
    }
}

extension StringProtocol {
    var words: [String] {
        split(whereSeparator: \.isLetter.negation).map { String($0) }
    }
}

extension Bool {
    var negation: Bool { !self }
}
