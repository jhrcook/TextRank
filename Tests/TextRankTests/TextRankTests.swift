@testable import TextRank
import XCTest

final class TextRankTests: XCTestCase {
    func testBuildSimpleTextRank() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        var textrank = TextRank(summarizeBy: .sentence)
        XCTAssertEqual(textrank.summarizeBy, TextRank.SummarizationOption.sentence)
        textrank = TextRank(summarizeBy: .word)
        XCTAssertEqual(textrank.summarizeBy, TextRank.SummarizationOption.word)
        textrank.summarizeBy = .sentence
        XCTAssertEqual(textrank.summarizeBy, TextRank.SummarizationOption.sentence)
    }

    func testTextSplittingAndPreparation() {
        let textrank = TextRank(summarizeBy: .sentence)
        XCTAssertEqual(textrank.modifyForTextComparisons("   HERE   "), "here")
        XCTAssertEqual(textrank.modifyForTextComparisons("   here   "), "here")
        XCTAssertEqual(textrank.modifyForTextComparisons("   here."), "here")
        XCTAssertEqual(textrank.modifyForTextComparisons("   here   there   "), "here   there")
        XCTAssertEqual(textrank.modifyForTextComparisons("   here\n"), "here")

        XCTAssertEqual(Set(textrank.splitIntoSubstrings("here there", .byWords)), Set(["here", "there"]))
        XCTAssertEqual(textrank.splitIntoSubstrings("here there", .bySentences), ["here there"])
        XCTAssertEqual(Set(textrank.splitIntoSubstrings("Here there. Way up high.", .bySentences)), Set(["Here there. ", "Way up high."]))
    }

    func testSummarizationMethods() {
        let text = """
            Welcome to the Swift community. Together we are working to build a programming language to empower everyone to turn their ideas into apps on any platform.

            Announced in 2014, the Swift programming language has quickly become one of the fastest growing languages in history. Swift makes it easy to write software that is incredibly fast and safe by design. Our goals for Swift are ambitious: we want to make programming simple things easy, and difficult things possible.

            For students, learning Swift has been a great introduction to modern programming concepts and best practices. And because it is open, their Swift skills will be able to be applied to an even broader range of platforms, from mobile devices to the desktop to the cloud.
        """

        let textrank = TextRank(summarizeBy: .sentence)
        let splitText = textrank.splitIntoTextMap(text)

        for (key, value) in splitText {
            XCTAssertTrue(key == key.lowercased())
            XCTAssertTrue(key == key.trimmingCharacters(in: .whitespacesAndNewlines))
            XCTAssertTrue(key == key.trimmingCharacters(in: .punctuationCharacters))
            XCTAssertTrue(value.count > 0)
        }

        textrank.buildGraph(text: Array(splitText.keys))

        for string in textrank.splitText.keys {
            XCTAssertTrue(textrank.textGraph.nodes.keys.contains(string))
        }
    }

    func testSentenceSimilarityMetric() {
        func near(_ x: Float, _ y: Float, epsilon: Float = 0.0001) -> Bool {
            return abs(x - y) <= epsilon
        }

        let textrank = TextRank(summarizeBy: .sentence)

        // Baisc test.
        var a = "dog cat mouse elephant"
        var b = "dog cat elephant"
        var expectedSimilarity: Float = 3 / (log(4) + log(3))
        XCTAssertTrue(near(textrank.similarity(between: a, and: b), expectedSimilarity))

        // Test to ignore stopwords.
        a = "dog cat mouse elephant a the it"
        b = "dog cat elephant"
        expectedSimilarity = 3 / (log(4) + log(3))
        XCTAssertTrue(near(textrank.similarity(between: a, and: b), expectedSimilarity))

        // Test to return 0 if no words in common.
        a = "dog cat mouse"
        b = "elephant pony lion"
        XCTAssertTrue(near(textrank.similarity(between: a, and: b), 0.0))

        // Test to return 0 if no words in common.
        a = "dog cat mouse"
        b = ""
        XCTAssertTrue(near(textrank.similarity(between: a, and: b), 0.0))
        a = ""
        b = "dog cat mouse"
        XCTAssertTrue(near(textrank.similarity(between: a, and: b), 0.0))
        a = ""
        b = ""
        XCTAssertTrue(near(textrank.similarity(between: a, and: b), 0.0))
    }

    func testEdgeSimilarities() {
        let text = "Here is a sentence. Here is another sentence. No connections to other units. Walrus tigers Carrol. Bengal tigers are cool."
        let textrank = TextRank(summarizeBy: .sentence)
        let splitText = textrank.splitIntoTextMap(text)
        textrank.buildGraph(text: Array(splitText.keys))

        let edgeWeights: [String: [String: Float]] = textrank.textGraph.edgeWeights

        // Edges with similarities should have non-zero edge weights.
        XCTAssert(edgeWeights["here is another sentence"]!["here is a sentence"]! > 0.0)
        XCTAssert(edgeWeights["bengal tigers are cool"]!["walrus tigers carrol"]! > 0.0)
        // All edges with this sentence should be of weight 0.
        XCTAssertNil(edgeWeights["no connections to other units"])
        // There should be no edge weights less than 1.0.
        for (_, links) in edgeWeights {
            for (_, value) in links {
                XCTAssertTrue(value >= 1.0)
            }
        }
    }

    func testPageRankConvergence() {
        let wikipediaOfSwifts = """
        The swifts are a family, Apodidae, of highly aerial birds. They are superficially similar to swallows, but are not closely related to any passerine species. Swifts are placed in the order Apodiformes with hummingbirds. The treeswifts are closely related to the true swifts, but form a separate family, the Hemiprocnidae.
        Resemblances between swifts and swallows are due to convergent evolution, reflecting similar life styles based on catching insects in flight.[citation needed]
        The family name, Apodidae, is derived from the Greek ἄπους (ápous), meaning "footless", a reference to the small, weak legs of these most aerial of birds.[1][2] The tradition of depicting swifts without feet continued into the Middle Ages, as seen in the heraldic martlet.
        Swifts are among the fastest of birds, and larger species like the white-throated needletail have been reported travelling at up to 169 km/h (105 mph)[6] in level flight. Even the common swift can cruise at a maximum speed of 31 metres per second (112 km/h; 70 mph). In a single year the common swift can cover at least 200,000 km.[7] and in a lifetime, about two million kilometers; enough to fly to the Moon five times over.[8]
        The wingtip bones of swiftlets are of proportionately greater length than those of most other birds. Changing the angle between the bones of the wingtips and forelimbs allows swifts to alter the shape and area of their wings to increase their efficiency and maneuverability at various speeds.[9] They share with their relatives the hummingbirds a unique ability to rotate their wings from the base, allowing the wing to remain rigid and fully extended and derive power on both the upstroke and downstroke.[10] The downstroke produces both lift and thrust, while the upstroke produces a negative thrust (drag) that is 60% of the thrust generated during the downstrokes, but simultaneously it contributes lift that is also 60% of what is produced during the downstroke. This flight arrangement might benefit the bird's control and maneuverability in the air.[11]
        The swiftlets or cave swiftlets have developed a form of echolocation for navigating through dark cave systems where they roost.[12] One species, the Three-toed swiftlet, has recently been found to use this navigation at night outside its cave roost too.
        Swifts occur on all the continents except Antarctica, but not in the far north, in large deserts, or on many oceanic islands.[13] The swifts of temperate regions are strongly migratory and winter in the tropics. Some species can survive short periods of cold weather by entering torpor, a state similar to hibernation.[12]
        Many have a characteristic shape, with a short forked tail and very long swept-back wings that resemble a crescent or a boomerang. The flight of some species is characterised by a distinctive "flicking" action quite different from swallows. Swifts range in size from the pygmy swiftlet (Collocalia troglodytes), which weighs 5.4 g and measures 9 cm (3.5 in) long, to the purple needletail (Hirundapus celebensis), which weighs 184 g (6.5 oz) and measures 25 cm (9.8 in) long.[12]
        The nest of many species is glued to a vertical surface with saliva, and the genus Aerodramus use only that substance, which is the basis for bird's nest soup. The eggs hatch after 19 to 23 days, and the young leave the nest after a further six to eight weeks. Both parents assist in raising the young.[12]
        Swifts as a family have smaller egg clutches and much longer and more variable incubation and fledging times than passerines with similarly sized eggs, resembling tubenoses in these developmental factors. Young birds reach a maximum weight heavier than their parents; they can cope with not being fed for long periods of time, and delay their feather growth when undernourished. Swifts and seabirds have generally secure nest sites, but their food sources are unreliable, whereas passerines are vulnerable in the nest but food is usually plentiful.[14][15]
        """

        let textrank = TextRank(summarizeBy: .sentence)
//        var pageRankResults: TextGraph<String>.PageRankResult = nil

        do {
            let pageRankResult = try textrank.summarise(wikipediaOfSwifts)
            // TEST: Need to write tests for the results.
            for (sentence, value) in pageRankResult.scores.sorted(by: { $0.value > $1.value }) {
                print("\(sentence.prefix(40)): \(value)")
            }
        } catch {
            XCTFail("PageRank errored: \(error.localizedDescription)")
        }
    }

    static var allTests = [
        ("testBuildSimpleTextRank", testBuildSimpleTextRank),
        ("testTextSplittingAndPreparation", testTextSplittingAndPreparation),
        ("testSummarizationMethods", testSummarizationMethods),
        ("testSentenceSimilarityMetric", testSentenceSimilarityMetric),
        ("testEdgeSimilarities", testEdgeSimilarities),
        ("testPageRankConvergence", testPageRankConvergence),
    ]
}
