//
//  File.swift
//
//
//  Created by Joshua on 11/17/20.
//

import Foundation

class TextGraph<T: Hashable> {
    private(set) var nodes = [T: Float]()
    private(set) var graph = [T: [T]]()
    private(set) var weights = [T: [T: Float]]()

    var startingScore: Float = 0.15
    var damping: Float = 0.85
    var convergence: Float = 0.01

    var numberOfNodes: Int {
        nodes.count
    }

    var numberOfEdges: Int {
        nodes.keys.reduce(0) {
            $0 + (graph[$1]?.count ?? 0)
        }
    }

    init(startingScore: Float, damping: Float, convergence: Float) {
        self.startingScore = startingScore
        self.damping = damping
        self.convergence = convergence
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
    }

    /// Add an edge between two nodes.
    /// - Parameters:
    ///   - from: source node
    ///   - to: destination node
    private func addEdgeToGraph(from: T, to: T) {
        if var fromNode = graph[from] {
            fromNode.append(to)
            graph[from] = fromNode
        } else {
            graph[from] = [to]
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
        if weights[from] == nil {
            weights[from] = [T: Float]()
        }
        weights[from]![to] = edgeWeight
    }
}
