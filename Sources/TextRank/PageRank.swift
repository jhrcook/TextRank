//
//  File.swift
//
//
//  Created by Joshua on 11/17/20.
//

import Foundation

extension TextGraph {
    /// Run PageRank on the nodes.
    func executePageRank(maximumIterations: Int = 1000) throws -> PageRankResult {
        if nodes.count < 2 {
            throw PageRankError.notEnoughtNodesToRunPageRank(nodes.count)
        }

        var rankedNodes = pageRankStep(nodes)
        var counter = 0
        var didConverge = true

        while !hasConverged(initial: rankedNodes, next: nodes) {
            nodes = rankedNodes
            rankedNodes = pageRankStep(nodes)
            counter += 1
            if counter > maximumIterations {
                print("PageRank failed to converge after \(maximumIterations) steps - stopping early.")
                didConverge = false
                break
            }
        }

        return PageRankResult(scores: nodes, didFinishSuccessfully: didConverge)
    }

    /// Execute a single step of the PageRank algorithm. Each node is iterated over once.
    /// - Parameter nodes: The nodes of the grpah.
    /// - Returns: The nodes with new scores.
    private func pageRankStep(_ nodes: Nodes) -> Nodes {
        var newNodes = Nodes()
        for node in nodes.keys {
            // PR(i) = (1-d)/N + d*score(i)
            newNodes[node] = (1 - damping) / Float(nodes.count) + (damping * score(for: node, in: nodes))
        }
        return newNodes
    }

    /// Calculate the PageRank score for a node.
    /// - Parameters:
    ///   - i: The node to find the score of.
    ///   - in: A set of nodes.
    /// - Returns: The score.
    private func score(for u: T, in nodes: Nodes) -> Float {
        var rank: Float = 0
        for v in nodesPointingTo(u) {
            let totalEdgeWeights = totalEdgeWeightFrom(v)
            rank += nodes[v]! * edgeWeight(v, u) / totalEdgeWeights
        }
        return rank
    }

    /// Has the Pagerank algorithm converged.
    /// - Parameters:
    ///   - a: initial set of nodes
    ///   - b: next set of nodes
    /// - Returns: A boolean to indicate whether the algorithm has converged.
    private func hasConverged(initial a: Nodes, next b: Nodes) -> Bool {
        let convergenceAchieved = b.map { key, value in
            abs((a[key] ?? 0) - value) <= convergenceThreshold
        }.filter { $0 }
        return convergenceAchieved.count == b.count
    }

    private func printNodes() {
        for (node, value) in nodes {
            print("node \(node): \(value)")
        }
        print("------------")
    }
}

extension TextGraph {
    struct PageRankResult {
        var scores: [T: Float]
        var didFinishSuccessfully: Bool

        func topHits(percent: Float) -> [Hit] {
            let n = Int((Float(scores.count) * max(min(percent, 1.0), 0.0)).rounded())
            return topHits(n: n)
        }

        func topHits(n: Int) -> [Hit] {
            var top = [Hit]()
            for (text, score) in scores.sorted(by: { $0.value > $1.value })[0 ..< n] {
                top.append(Hit(text: text, score: score))
            }
            return top
        }

        struct Hit {
            var text: T
            var score: Float
        }
    }
}

extension TextGraph {
    enum PageRankError: Error, LocalizedError {
        case notEnoughtNodesToRunPageRank(Int)

        var errorDescription: String? {
            switch self {
            case let .notEnoughtNodesToRunPageRank(numNodes):
                return NSLocalizedString("There are not enough nodes (\(numNodes)) in the graph to run PageRank.", comment: "")
            }
        }
    }
}
