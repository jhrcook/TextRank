//
//  File.swift
//
//
//  Created by Joshua on 11/17/20.
//

import Foundation

class TextGraph<T: Hashable> {
    typealias Nodes = [T: Float]
    typealias Graph = [T: [T]]
    typealias Matrix = [T: [T: Float]]

    var nodes = Nodes()
    var numberOfLinksFrom = [T: Int]()
    var graph = Graph() // [to j][from i]
    var edgeWeights = Matrix() // [from i][to j]

    var startingScore: Float = 0.15 // Replace with < 1/|nodes| >
    var damping: Float = 0.85
    var convergenceThreshold: Float = 0.001 // 0.0001

    var numberOfNodes: Int {
        nodes.count
    }

    var numberOfEdges: Int {
        nodes.keys.reduce(0) {
            $0 + (graph[$1]?.count ?? 0)
        }
    }

    init(startingScore: Float, damping: Float, convergenceThreshold: Float) {
        self.startingScore = startingScore
        self.damping = damping
        self.convergenceThreshold = convergenceThreshold
    }

    init() {}

    /// Add a weighted edge to the graph.
    /// - Parameters:
    ///   - from: source node
    ///   - to: destination node
    ///   - weight: weight of the edge
    func addEdge(from: T, to: T, weight: Float = 1) {
        addEdgeToGraph(from: from, to: to)
        for node in [from, to] {
            initializeNodes(node)
        }
        set(edgeWeight: weight, from: from, to: to)
        incrementEdgeCount(from: from)
    }

    /// Add an edge between two nodes.
    /// - Parameters:
    ///   - from: source node
    ///   - to: destination node
    private func addEdgeToGraph(from: T, to: T) {
        if var toNode = graph[to] {
            toNode.append(from)
            graph[to] = toNode
        } else {
            graph[to] = [from]
        }
    }

    /// Add a new node.
    /// - Parameter node: node identifier
    private func initializeNodes(_ node: T) {
        nodes[node] = startingScore
    }

    /// Set the weight of an edge.
    /// - Parameters:
    ///   - edgeWeight: weight to set
    ///   - from: source node
    ///   - to: destination node
    private func set(edgeWeight: Float, from: T, to: T) {
        if edgeWeights[from] == nil {
            edgeWeights[from] = [T: Float]()
        }
        edgeWeights[from]![to] = edgeWeight
    }

    /// Increment the count for the number of links from a node.
    /// - Parameter from: source node
    private func incrementEdgeCount(from: T) {
        if let n = numberOfLinksFrom[from] {
            numberOfLinksFrom[from] = n + 1
        } else {
            numberOfLinksFrom[from] = 1
        }
    }
}

// MARK: - Accessing graph information.

extension TextGraph {
    func edgeWeight(_ from: T, _ to: T) -> Float {
        return edgeWeights[from]?[to] ?? 0.0
    }

    func nodesPointingTo(_ node: T) -> [T] {
        return graph[node] ?? []
    }

    func numberOfLinksFrom(_ node: T) -> Int {
        return numberOfLinksFrom[node] ?? 0
    }

    func totalEdgeWeightFrom(_ node: T) -> Float {
        if let allEdgeWeights = edgeWeights[node] {
            return allEdgeWeights.values.reduce(0.0, +)
        } else {
            return 0.0
        }
    }
}
