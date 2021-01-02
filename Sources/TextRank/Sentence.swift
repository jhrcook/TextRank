//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

struct Sentence: Hashable {
    let text: String
    let cleanText: String

    init(text: String) {
        self.text = text
        cleanText = Sentence.clean(text)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }

    static func clean(_ s: String) -> String {
        return s
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
    }
}
