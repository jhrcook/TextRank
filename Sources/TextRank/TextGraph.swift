//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

public class TextGraph {
    public typealias NodeList = [Sentence: Float]

    // MARK: PageRank meta-constants

    public var damping: Float = 0.85
    public var epsilon: Float = 0.0001

    // MARK: Graph components

    public var nodes = NodeList()
    public var edges = [Sentence: NodeList]()

    public init() {}

    public init(damping: Float) {
        self.damping = damping
    }

    public init(damping: Float, epsilon: Float) {
        self.damping = damping
        self.epsilon = epsilon
    }

    enum TextGraphError: Error, LocalizedError {
        case NonpositiveEdgeWeight(value: Float)

        public var errorDescription: String? {
            switch self {
            case let .NonpositiveEdgeWeight(value):
                return NSLocalizedString("Negative edge weights (\(value)) are not allowed.", comment: "")
            }
        }
    }

    /// Create an edge in the graph.
    /// - Parameters:
    ///   - a: First node.
    ///   - b: Second node.
    ///   - weight: Weight of the edge (default is 1). The edge weight must be greater than 0, else neither the nodes nor edge are added.
    public func addEdge(from a: Sentence, to b: Sentence, withWeight weight: Float = 1.0) throws {
        if weight <= 0 {
            throw TextGraphError.NonpositiveEdgeWeight(value: weight)
        }
        if weight > 0 {
            for n in [a, b] {
                setValue(of: n)
            }
            setEdge(from: a, to: b, withWeight: weight)
            setEdge(from: b, to: a, withWeight: weight)
        }
    }

    /// Add a node.
    /// - Parameter node: Node to add. If it already exists, it gets overwritten.
    /// - Parameter value: Value to assign to node (default 1.0).
    func setValue(of node: Sentence, value: Float = 1.0) {
        nodes[node] = value
    }

    /// Set the weight of the edge connecting two nodes.
    /// - Parameters:
    ///   - a: First node.
    ///   - b: Second node.
    ///   - weight: Edge weight.
    func setEdge(from a: Sentence, to b: Sentence, withWeight weight: Float) {
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
    public func getValue(of node: Sentence) -> Float {
        return nodes[node] ?? 0.0
    }

    /// Get the edge weight between two nodes.
    /// - Parameters:
    ///   - a: First node.
    ///   - b: Second node.
    /// - Returns: Returns the edge weight between two nodes or 0 if there is no edge.
    public func getEdgeWeight(from a: Sentence, to b: Sentence) -> Float {
        if let edges = edges[a] {
            return edges[b] ?? 0.0
        }
        return 0.0
    }

    /// Get the total weights of the edges from a node.
    /// - Parameter node: The node.
    /// - Returns: The summed edge weight or 0 if none exist.
    public func getTotalEdgeWeight(of node: Sentence) -> Float {
        if let edges = edges[node] {
            return edges.values.reduce(0.0, +)
        }
        return 0.0
    }

    /// Get the number of edges connected to a node.
    /// - Parameter node: The node.
    /// - Returns: The number of edges connected to the node.
    public func getNumberOfEdges(from node: Sentence) -> Int {
        return edges[node]?.count ?? 0
    }

    public func clearGraph() {
        nodes.removeAll()
        edges.removeAll()
    }
}

extension TextGraph {
    public struct PageRankResult {
        public let didConverge: Bool
        public let iterations: Int
        public let results: NodeList
    }

    enum PageRankError: Error {
        case EmptyNodeList, EmptyEdgeList
    }

    /// Run the PageRank algorithm on the previously established graph. If the algorithm does not converge,
    /// a result is still returned with the `PageRankResult.didConverge` property set to `false`.
    /// - Parameter maximumIterations: The maximum number of iterations (default 100).
    /// - Returns: The results of the PageRank algorithm.
    public func runPageRank(maximumIterations: Int = 100) throws -> PageRankResult {
        // Check that there are nodes and edges.
        if nodes.isEmpty {
            throw PageRankError.EmptyNodeList
        } else if edges.isEmpty {
            throw PageRankError.EmptyEdgeList
        }

        setInitialNodeValues()
        for i in 0 ..< maximumIterations {
            let newNodes = runRoundOfPageRank(with: nodes)
            if hasConverged(nodes, newNodes) {
                return PageRankResult(didConverge: true, iterations: i, results: newNodes)
            }
            nodes = newNodes
        }
        return PageRankResult(didConverge: false, iterations: maximumIterations, results: nodes)
    }

    /// Run a single iteration of the PageRank algorithm on a node list. The edge list does not change so
    /// it is taken from the previously established graph.
    /// - Parameter nodes: The node list to iterate over.
    /// - Returns: Another nodelist with new ranks.
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

    /// Get the sum of the values of the neighbors of a node.
    /// - Parameters:
    ///   - node: The node of whose neighbors to sum.
    ///   - nodelist: The nodelist to get scores from.
    /// - Returns: The sum.
    func getSumOfNeighborValues(_ node: Sentence, in nodelist: NodeList) -> Float {
        guard let neighbors = edges[node] else { return 0.0 }
        return neighbors
            .map { (nodelist[$0.key] ?? 0.0) * $0.value / getTotalEdgeWeight(of: $0.key) }
            .reduce(0.0, +)
    }

    /// Initialize node values equally over all nodes.
    func setInitialNodeValues() {
        let initialValue: Float = 1.0 / Float(nodes.count)
        for n in nodes.keys {
            nodes[n] = initialValue
        }
    }

    /// Has the PageRank algorithm stopped improving.
    /// - Parameters:
    ///   - n0: Nodelist of the previous step.
    ///   - n1: Nodelist of the current step.
    /// - Returns: Whether the nodes' scores have not changed substantially (controlled by `TextGraph.epsilon`).
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
