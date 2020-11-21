import Foundation

class TextRank {
    let text: String
    let summarizeBy: SummarizationOption
    var textGraph = TextGraph<String>()
    var splitText = [String: [String]]() // modified sentence: original sentence

    public init(_ text: String, by: SummarizationOption) {
        self.text = text
        summarizeBy = by
    }

    /// Run the summarization algorithm on the text.
    /// - Returns: A dictionary mapping substrings of the original text to their summarization values.
    public func summarise() -> [String: Float] {
        buildSplitTextMapping()
        buildGraph()
        runPageRank()
        return textGraph.nodes
    }

    /// Build the dictionary mapping the modified strings to the original strings parsed from the text.
    func buildSplitTextMapping() {
        let textSplit = split(text, by: summarizeBy)
        let textSplitCleaned = textSplit.map(modifyForTextComparisons)
        for (cleanText, originalText) in zip(textSplitCleaned, textSplit) {
            if var mappedText = splitText[cleanText] {
                mappedText.append(originalText)
                splitText[cleanText] = mappedText
            } else {
                splitText[cleanText] = [originalText]
            }
        }
    }

    /// Build the text graph as the connection of all substrings of the parsed text.
    func buildGraph() {
        let text = Array(splitText.keys)
        for i in 0 ..< text.count {
            for j in i + 1 ..< text.count {
                textGraph.addEdge(from: text[i], to: text[j], weight: Float.random(in: 0 ... 1))
                textGraph.addEdge(from: text[j], to: text[i], weight: Float.random(in: 0 ... 1))
            }
        }
    }

    /// Run the PageRank algorithm on the text graph.
    func runPageRank() {
        if textGraph.nodes.count > 0 {
            textGraph.executePageRank()
        }
    }

    /// Split the text into its substrings.
    /// - Parameters:
    ///   - text: Original text.
    ///   - by: How to split the text.
    /// - Returns: An array of *unique* strings.
    func split(_ text: String, by: SummarizationOption) -> [String] {
        switch by {
        case .sentence:
            return splitIntoSubstrings(text, .bySentences)
        case .word:
            return splitIntoSubstrings(text, .byWords)
        }
    }
}

// MARK: - Modifying text

extension TextRank {
    /// Split some text into its substrings.
    /// - Parameters:
    ///   - text: Original text.
    ///   - by: How to split the text.
    /// - Returns: An array of *unique* strings.
    func splitIntoSubstrings(_ text: String, _ by: NSString.EnumerationOptions) -> [String] {
        var x = [String]()
        text.enumerateSubstrings(in: text.range(of: text)!, options: [by, .localized]) { substring, _, _, _ in
            if let substring = substring, !substring.isEmpty {
                x.append(substring)
            }
        }
        return Array(Set(x))
    }

    /// Modify a string to be compared against all other strings.
    /// - Parameter string: Original string.
    /// - Returns: Modified string.
    func modifyForTextComparisons(_ string: String) -> String {
        return string
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
    }
}

// MARK: - TextRank enums

extension TextRank {
    enum SummarizationOption {
        case sentence, word
    }
}
