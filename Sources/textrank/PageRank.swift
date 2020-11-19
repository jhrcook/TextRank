//
//  File.swift
//
//
//  Created by Joshua on 11/17/20.
//

import Foundation

extension TextGraph {
    /// Run PageRank on the nodes.
    func executePageRank() {
        var rankedNodes = pageRankStep(nodes)
        while !hasConverged(initial: rankedNodes, next: nodes) {
            nodes = rankedNodes
            rankedNodes = pageRankStep(nodes)
        }
        printNodes()
    }

    /// Execute a single step of the PageRank algorithm. Each node is iterated over once.
    /// - Parameter nodes: The nodes of the grpah.
    /// - Returns: The nodes with new scores.
    private func pageRankStep(_ nodes: Nodes) -> Nodes {
        var newNodes = Nodes()
        for node in nodes.keys {
            // PR(i) = (1-d)/N + d*score(i)
            newNodes[node] = (1 - damping) / Float(nodes.count) + damping * score(for: node, in: nodes)
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
            rank += nodes[v]! * edgeWeight(v, u) / totalEdgeWeightFrom(v)
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
