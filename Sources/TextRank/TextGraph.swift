//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

class TextGraph {
    typealias NodeList = [Sentence: Float]

    var damping: Float
    let epsilon: Float = 0.0001

    var nodes = NodeList()
    var edges = [Sentence: NodeList]()

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
            }
            setEdgeWeight(from: a, to: b, weight: weight)
            setEdgeWeight(from: b, to: a, weight: weight)
        }
    }

    /// Add a node.
    /// - Parameter node: Node to add. If it already exists, it gets overwritten.
    func setValue(of node: Sentence, value: Float = 1.0) {
        nodes[node] = value
    }

    /// Set the weight of the edge connecting two nodes.
    /// - Parameters:
    ///   - a: First node.
    ///   - b: Second node.
    ///   - weight: Edge weight.
    func setEdgeWeight(from a: Sentence, to b: Sentence, weight: Float) {
        if var existingEdges = edges[a] {
            existingEdges[b] = weight
            edges[a] = existingEdges
        } else {
            edges[a] = [b: weight]
        }
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
        if let edges = edges[a] {
            return edges[b] ?? 0.0
        }
        return 0.0
    }

    /// Get the total weights of the edges from a node.
    /// - Parameter node: The node.
    /// - Returns: The summed edge weight or 0 if none exist.
    func getTotalEdgeWeight(of node: Sentence) -> Float {
        if let edges = edges[node] {
            return edges.values.reduce(0.0, +)
        }
        return 0.0
    }

    func getNumberOfEdges(from node: Sentence) -> Int {
        return edges[node]?.count ?? 0
    }
}

extension TextGraph {
    func runPageRank(maximumIterations: Int = 100) {
        setInitialNodeValues()
        for _ in 0 ..< maximumIterations {
            let newNodes = runRoundOfPageRank(with: nodes)
            if hasConverged(nodes, newNodes) {
                return
            }
            nodes = newNodes
        }
        // Need to deal with return type and if has converged.
    }

    func runRoundOfPageRank(with nodes: NodeList) -> NodeList {
        var nextNodes = nodes
        let dampingConstant: Float = (1 - damping) / Float(nodes.count)
        for n in nodes.keys {
            let score = getSumOfNeighborValues(n, in: nodes)
            let nodeEdgeWeights = getTotalEdgeWeight(of: n)
            if nodeEdgeWeights > 0.0 {
                nextNodes[n] = dampingConstant + damping * score / nodeEdgeWeights
            } else {
                nextNodes[n] = 0.0
            }
        }
        return nextNodes
    }

    func getSumOfNeighborValues(_ node: Sentence, in nodelist: NodeList) -> Float {
        edges[node]?.keys.map { nodelist[$0] ?? 0.0 }.reduce(0.0, +) ?? 0.0
    }

    func setInitialNodeValues() {
        let initialValue: Float = 1.0 / Float(nodes.count)
        for n in nodes.keys {
            nodes[n] = initialValue
        }
    }

    func hasConverged(_ n0: [Sentence: Float], _ n1: [Sentence: Float]) -> Bool {
        for (node, node0value) in n0 {
            if let node1Value = n1[node] {
                if abs(node0value - node1Value) > epsilon {
                    return false
                }
            }
        }
        return true
    }
}
