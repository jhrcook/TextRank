//
//  File.swift
//
//
//  Created by Joshua on 1/1/21.
//

import Foundation

struct TextGraph {
    var damping: Float

    var nodes = [String: Float]()
    var edgeWeights = [String: [String: Float]]()
    var connectingEdgeCounts = [String: Int]()

    init(damping: Float = 0.85) {
        self.damping = damping
    }
}
