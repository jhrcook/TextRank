import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return ["TextRankTests.swift", "TextGraphTests.swift", "SentenceTests.swift"]
    }
#endif
