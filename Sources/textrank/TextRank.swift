import Foundation

struct TextRank {
    var text: String
    var summarizeBy: SummarizationOption

    init(text: String, by: SummarizationOption) {
        self.text = text
        summarizeBy = by
    }
}

// MARK: - TextRank enums

extension TextRank {
    enum SummarizationOption {
        case sentence, word
    }
}
