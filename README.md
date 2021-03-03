# TextRank

![Swift](https://img.shields.io/badge/Swift-Package-FA7343.svg?style=flat&logo=swift)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![SwiftFormat](https://img.shields.io/badge/SwfitFormat-enabled-A166E6)](https://github.com/nicklockwood/SwiftFormat)
[![GitHub Actions CI](https://github.com/jhrcook/TextRank/actions/workflows/GitHub%20Actions%20CI/badge.svg)](https://github.com/jhrcook/TextRank/actions/workflows/CI.yml)

A Swift package that implements the ['TextRank' algorithm](https://web.eecs.umich.edu/~mihalcea/papers/mihalcea.emnlp04.pdf) for summarization.
This algorithm uses the [PageRank (PR) algorithm](https://en.wikipedia.org/wiki/PageRank) to rank nodes by centrality in a weighted, undirected network where the nodes are sentences and edges indicate the degree of similarity of two sentences.

*This package is functional, but young. Please open an issue if you find any bugs or have any feature requests.*

Stop words were acquired from [Ranks NL](https://www.ranks.nl/stopwords).
Please open an issue to request additional language support.

### Example

```swift
import TextRank

let textRank = TextRank(text: myParagraph)
let rankedResults = textRank.runPageRank()
```

The `rankedResults` is a `TextGraph.PageRankResult` struct with three properties:

1. `didConverge`: whether or not the PR algorithm converged
2. `iterations`: the number of iterations required for the PR algorithm to converge
3. `results`: a `TextGraph.NodeList` which is a type alias for `[Sentence: Float]` that holds the final rankings from the PR algorithm

The `PageRankResult.results` object holds the final node list after running PR.
Under the hood, it is a dictionary mapping each sentence to a rank.
The keys are of type `Sentence` which has properties for the original sentence `text` and the set of words in the sentence `words`.
Below is an example of how to obtain an array of sentences sorted by their rankings in decreasing order.

```swift
let sortedSentences: [String] = rankedResults
	.results
	.sorted { $0.value < $1.value }
	.map { $0.key }
```

---

### Similar projects

This code base is based off of the [original Python implementation](https://github.com/summanlp/textrank).
These is another Swift package, ['SwiftTextRank'](https://github.com/goncharik/SwiftTextRank) that implements this algorithm.
