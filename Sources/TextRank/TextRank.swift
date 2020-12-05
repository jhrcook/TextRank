import Foundation

class TextRank {
    // MARK: User-facing variables

    public var summarizeBy: SummarizationOption
    public var textGraph: TextGraph<String>

    // MARK: Internal variables

    var splitText = [String: [String]]() // modified sentence: original sentence

    // MARK: Initializers

    /// Initialize a `TextRank` object by declaring how to split the text.
    /// - Parameter summarizeBy: A single unit of the text.
    public init(summarizeBy: SummarizationOption) {
        self.summarizeBy = summarizeBy
        textGraph = TextGraph<String>()
    }

    /// Initlize a `TextRank` object by declaring how to split the text and the parameters for the PageRank algorithm.
    /// - Parameters:
    ///   - summarizeBy: A single unit of the text.
    ///   - startingScore: The initial score of each node.
    ///   - damping: The probability of leaving the current 'page' and randomly selecting another.
    ///   - convergenceThreshold: When the difference in scores between iterations is less than this value, the algorithm terminates.
    public init(summarizeBy: SummarizationOption, startingScore: Float, damping: Float, convergenceThreshold: Float) {
        self.summarizeBy = summarizeBy
        textGraph = TextGraph<String>(startingScore: startingScore, damping: damping, convergenceThreshold: convergenceThreshold)
    }

    /// Run the summarization algorithm on the text.
    /// - Returns: A dictionary mapping substrings of the original text to their summarization values.
    public func summarise(_ text: String) -> [String: Float] {
        splitText = splitIntoTextMap(text)
        buildGraph(text: Array(splitText.keys))
        textGraph.pruneUnreachableNodes() // still needs to be implemented
        runPageRank()
        return textGraph.nodes
    }

    /// Build the dictionary mapping the modified strings to the original strings parsed from the text.
    func splitIntoTextMap(_ text: String) -> [String: [String]] {
        let textSplit = split(text, by: summarizeBy)
        let textSplitCleaned = textSplit.map(modifyForTextComparisons)
        var textSplitMap = [String: [String]]()
        for (cleanText, originalText) in zip(textSplitCleaned, textSplit) {
            if var mappedText = textSplitMap[cleanText] {
                mappedText.append(originalText)
                textSplitMap[cleanText] = mappedText
            } else {
                textSplitMap[cleanText] = [originalText]
            }
        }
        return textSplitMap
    }

    /// Build the text graph as the connection of all substrings of the parsed text.
    func buildGraph(text: [String]) {
        for i in 0 ..< text.count {
            for j in i + 1 ..< text.count {
                let edgeWeight = similarity(between: text[i], and: text[j])
                textGraph.addEdge(from: text[i], to: text[j], weight: edgeWeight)
                textGraph.addEdge(from: text[j], to: text[i], weight: edgeWeight)
            }
        }
    }

    /// Run the PageRank algorithm on the text graph.
    func runPageRank() {
        if textGraph.nodes.count > 1 {
            textGraph.executePageRank()
        } else {
            print("Cannot execute PageRank on a graph with less than 2 nodes.")
        }
    }

    /// Calculate the similarity between two strings.
    /// - Parameters:
    ///   - a: string one
    ///   - b: string two
    /// - Returns: A measure of similarity.
    func similarity(between a: String, and b: String) -> Float {
        let stopWords = StopWords.english
        let aWords = Set(splitIntoSubstrings(a, .byWords)).filter { !stopWords.contains($0) }
        let bWords = Set(splitIntoSubstrings(b, .byWords)).filter { !stopWords.contains($0) }
        let nWordsInCommon = aWords.intersection(bWords).count
        let logAWords = log10(Float(aWords.count))
        let logBWords = log10(Float(bWords.count))
        if aWords.count == 0 || bWords.count == 0 || nWordsInCommon == 0 || logAWords + logBWords == 0 {
            return 0.0
        }

        return max(Float(nWordsInCommon) / (logAWords + logBWords), 1)
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
        if text.isEmpty { return [""] }

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
