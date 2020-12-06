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
        The swifts are a family, Apodidae, of highly aerial birds.
        They are superficially similar to swallows, but are not closely related to any passerine species.
        Swifts are placed in the order Apodiformes with hummingbirds.
        The treeswifts are closely related to the true swifts, but form a separate family, the Hemiprocnidae.
        Resemblances between swifts and swallows are due to convergent evolution, reflecting similar life styles based on catching insects in flight.
        The family name, Apodidae, is derived from the Greek ἄπους (ápous), meaning 'footless', a reference to the small, weak legs of these most aerial of birds.
        The tradition of depicting swifts without feet continued into the Middle Ages, as seen in the heraldic martlet.
        Swifts are among the fastest of birds, and larger species like the white-throated needletail have been reported travelling at up to 169 km/h (105 mph) in level flight.
        Even the common swift can cruise at a maximum speed of 31 metres per second.
        In a single year the common swift can cover at least 200,000 km and in a lifetime, about two million kilometers; enough to fly to the Moon five times over.
        The wingtip bones of swiftlets are of proportionately greater length than those of most other birds.
        Changing the angle between the bones of the wingtips and forelimbs allows swifts to alter the shape and area of their wings to increase their efficiency and maneuverability at various speeds.
        They share with their relatives the hummingbirds a unique ability to rotate their wings from the base, allowing the wing to remain rigid and fully extended and derive power on both the upstroke and downstroke.
        The downstroke produces both lift and thrust, while the upstroke produces a negative thrust (drag) that is 60% of the thrust generated during the downstrokes, but simultaneously it contributes lift that is also 60% of what is produced during the downstroke.
        This flight arrangement might benefit the bird's control and maneuverability in the air.
        The swiftlets or cave swiftlets have developed a form of echolocation for navigating through dark cave systems where they roost.
        One species, the Three-toed swiftlet, has recently been found to use this navigation at night outside its cave roost too.
        Swifts occur on all the continents except Antarctica, but not in the far north, in large deserts, or on many oceanic islands.
        The swifts of temperate regions are strongly migratory and winter in the tropics.
        Some species can survive short periods of cold weather by entering torpor, a state similar to hibernation.
        Many have a characteristic shape, with a short forked tail and very long swept-back wings that resemble a crescent or a boomerang.
        The flight of some species is characterised by a distinctive 'flicking' action quite different from swallows.
        Swifts range in size from the pygmy swiftlet (Collocalia troglodytes), which weighs 54 g and measures 9 cm (35 in) long, to the purple needletail (Hirundapus celebensis), which weighs 184 g (65 oz) and measures 25 cm (98 in) long.
        The nest of many species is glued to a vertical surface with saliva, and the genus Aerodramus use only that substance, which is the basis for bird's nest soup.
        The eggs hatch after 19 to 23 days, and the young leave the nest after a further six to eight weeks.
        Both parents assist in raising the young.
        Swifts as a family have smaller egg clutches and much longer and more variable incubation and fledging times than passerines with similarly sized eggs, resembling tubenoses in these developmental factors.
        Young birds reach a maximum weight heavier than their parents; they can cope with not being fed for long periods of time, and delay their feather growth when undernourished.
        Swifts and seabirds have generally secure nest sites, but their food sources are unreliable, whereas passerines are vulnerable in the nest but food is usually plentiful.
        """

        struct KnownResults {
            let index: Int
            let score: Float
        }

        let knownScores: [String: KnownResults] = [
            "swifts are among the fastest of birds, and larger species like the white-throated needletail have been reported travelling at up to 169 km/h (105 mph) in level flight": KnownResults(index: 1, score: 0.30),
            "changing the angle between the bones of the wingtips and forelimbs allows swifts to alter the shape and area of their wings to increase their efficiency and maneuverability at various speeds": KnownResults(index: 5, score: 0.24),
            "resemblances between swifts and swallows are due to convergent evolution, reflecting similar life styles based on catching insects in flight": KnownResults(index: 3, score: 0.27),
            "swifts as a family have smaller egg clutches and much longer and more variable incubation and fledging times than passerines with similarly sized eggs, resembling tubenoses in these developmental factors": KnownResults(index: 2, score: 0.28),
            "the treeswifts are closely related to the true swifts, but form a separate family, the hemiprocnidae": KnownResults(index: 4, score: 0.24),
            "swifts range in size from the pygmy swiftlet (collocalia troglodytes), which weighs 54 g and measures 9 cm (35 in) long, to the purple needletail (hirundapus celebensis), which weighs 184 g (65 oz) and measures 25 cm (98 in) long": KnownResults(index: 6, score: 0.21),
            "the swifts are a family, apodidae, of highly aerial birds": KnownResults(index: 0, score: 0.30),
            "young birds reach a maximum weight heavier than their parents; they can cope with not being fed for long periods of time, and delay their feather growth when undernourished": KnownResults(index: 9, score: 0.19),
            "swifts and seabirds have generally secure nest sites, but their food sources are unreliable, whereas passerines are vulnerable in the nest but food is usually plentiful": KnownResults(index: 11, score: 0.19),
            "swifts occur on all the continents except antarctica, but not in the far north, in large deserts, or on many oceanic islands": KnownResults(index: 16, score: 0.16),
            "swifts are placed in the order apodiformes with hummingbirds": KnownResults(index: 10, score: 0.19),
            "some species can survive short periods of cold weather by entering torpor, a state similar to hibernation": KnownResults(index: 23, score: 0.13),
            "the nest of many species is glued to a vertical surface with saliva, and the genus aerodramus use only that substance, which is the basis for bird's nest soup": KnownResults(index: 13, score: 0.17),
            "the swifts of temperate regions are strongly migratory and winter in the tropics": KnownResults(index: 14, score: 0.17),
            "the tradition of depicting swifts without feet continued into the middle ages, as seen in the heraldic martlet": KnownResults(index: 17, score: 0.16),
            "many have a characteristic shape, with a short forked tail and very long swept-back wings that resemble a crescent or a boomerang": KnownResults(index: 24, score: 0.11),
            "one species, the three-toed swiftlet, has recently been found to use this navigation at night outside its cave roost too": KnownResults(index: 15, score: 0.16),
            "the flight of some species is characterised by a distinctive 'flicking' action quite different from swallows": KnownResults(index: 22, score: 0.14),
            "they are superficially similar to swallows, but are not closely related to any passerine species": KnownResults(index: 8, score: 0.20),
            "the wingtip bones of swiftlets are of proportionately greater length than those of most other birds": KnownResults(index: 18, score: 0.15),
            "the family name, apodidae, is derived from the greek ἄπους (ápous), meaning 'footless', a reference to the small, weak legs of these most aerial of birds": KnownResults(index: 19, score: 0.15),
            "the eggs hatch after 19 to 23 days, and the young leave the nest after a further six to eight weeks": KnownResults(index: 26, score: 0.09),
            "they share with their relatives the hummingbirds a unique ability to rotate their wings from the base, allowing the wing to remain rigid and fully extended and derive power on both the upstroke and downstroke": KnownResults(index: 20, score: 0.14),
            "in a single year the common swift can cover at least 200,000 km and in a lifetime, about two million kilometers; enough to fly to the moon five times over": KnownResults(index: 12, score: 0.18),
            "this flight arrangement might benefit the bird's control and maneuverability in the air": KnownResults(index: 21, score: 0.14),
            "even the common swift can cruise at a maximum speed of 31 metres per second": KnownResults(index: 7, score: 0.20),
            "the swiftlets or cave swiftlets have developed a form of echolocation for navigating through dark cave systems where they roost": KnownResults(index: 25, score: 0.10),
            "both parents assist in raising the young": KnownResults(index: 27, score: 0.07),
            "the downstroke produces both lift and thrust, while the upstroke produces a negative thrust (drag) that is 60% of the thrust generated during the downstrokes, but simultaneously it contributes lift that is also 60% of what is produced during the downstroke": KnownResults(index: 28, score: 0.05),
        ]

        func near(_ x: Float, _ y: Float, epsilon: Float = 0.0001) -> Bool {
            return abs(x - y) <= epsilon
        }

        let textrank = TextRank(summarizeBy: .sentence)
        do {
            let pageRankResult = try textrank.summarise(wikipediaOfSwifts)
            XCTAssertTrue(pageRankResult.didFinishSuccessfully)
            let tophits = pageRankResult.topHits(percent: 1.00)
            for (i, top) in tophits.enumerated() {
                // print("\"\(top.text)\": KnownResults(index: , score: 0.),")
                let known_idx = knownScores[top.text]!.index
                XCTAssertTrue(abs(known_idx - i) <= 1)
            }
            for top in tophits {
                let known_score = knownScores[top.text]!.score
                XCTAssertTrue(near(known_score, top.score, epsilon: 0.1))
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
