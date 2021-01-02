//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

class TextGraph {
    var damping: Float

    var nodes = [Sentence: Float]()
    var edgeWeights = [Set<Sentence>: Float]()
    var connectingEdgeCounts = [Sentence: Int]()

    init(damping: Float = 0.85) {
        self.damping = damping
    }

    /// Create an edge in the graph.
    /// - Parameters:
    ///   - a: First node.
    ///   - b: Second node.
    ///   - weight: Weight of the edge (default is 1).
    ///   - force: If the edge weight is 0, should the edge (and nodes) be created (default is `false`)?
    func addEdge(from a: Sentence, to b: Sentence, withWeight weight: Float = 1.0, force: Bool = false) {
        if weight > 0 || force {
            for n in [a, b] {
                setValue(of: n)
                incrementEdgeCount(of: n)
            }
            setEdgeWeight(a, b, weight: weight)
        }
    }

    /// Add a node.
    /// - Parameter node: Node to add. If it already exists, it gets overwritten.
    func setValue(of node: Sentence, value: Float = 1.0) {
        nodes[node] = value
    }

    /// Increment the edge count for a node.
    /// - Parameter node: The node with a new edge.
    func incrementEdgeCount(of node: Sentence) {
        if let currentCount = connectingEdgeCounts[node] {
            connectingEdgeCounts[node] = currentCount + 1
        } else {
            connectingEdgeCounts[node] = 1
        }
    }

    /// Set the weight of the edge connecting two nodes.
    /// - Parameters:
    ///   - a: First node.
    ///   - b: Second node.
    ///   - weight: Edge weight.
    func setEdgeWeight(_ a: Sentence, _ b: Sentence, weight: Float) {
        edgeWeights[Set([a, b])] = weight
    }

    /// Get the value of a node.
    /// - Parameter node: The node.
    /// - Returns: The current value of a node or 0 if it does not exist.
    func getValue(of node: Sentence) -> Float {
        return nodes[node] ?? 0.0
    }

    /// Get the edge weight between two nodes.
    /// - Parameters:
    ///   - a: First node.
    ///   - b: Second node.
    /// - Returns: Returns the edge weight between two nodes or 0 if there is no edge.
    func getEdgeWeight(from a: Sentence, to b: Sentence) -> Float {
        return edgeWeights[Set([a, b])] ?? 0.0
    }

    /// Get the number of edges from a node.
    /// - Parameter node: The node.
    /// - Returns: The number of edges or 0 if none exist.
    func getNumberOfEdges(from node: Sentence) -> Int {
        return connectingEdgeCounts[node] ?? 0
    }
}
