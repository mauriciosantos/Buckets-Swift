//
//  Graph.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/19/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A simple directed graph: that is, one with no loops (edges
/// connected at both ends to the same vertex) and no more than one edge
/// in the same direction between any two different vertices.
/// All vertices in the graph are unique. Edges are not allowed to be generic types.
/// The preferred way to acess and insert vertices or edges is using subscript notation. Example:
/// `graph["NY", "Boston"] = distance`
///
/// Conforms to `Sequence`.
public struct Graph<Vertex: Hashable, Edge> {
    
    fileprivate typealias GraphNode = VertexNode<Vertex, Edge>
    
    // MARK: Creating a Graph
    
    /// Creates an empty graph.
    public init() {}
    
    
    // MARK: Querying a Graph
    
    /// Number of vertices stored in the graph.
    public var count: Int  {
        return nodes.count
    }
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// Returns `true` if every pair of distinct vertices is connected by a
    /// unique edge (one in each direction).
    public var isComplete: Bool {
        return !nodes.values.contains { $0.adjacencyList.count != count - 1 }
    }
    
    /// Returns `true` if there's not a path starting and ending
    /// at the same vertex.
    public var isAcyclic: Bool {
        var visited = Set<GraphNode>()
        for sourceNode in nodes.values {
            var path = [Vertex]()
            for neighbor in sourceNode.successors {
                if containsPathFrom(neighbor, to: sourceNode, visited: &visited, path: &path) {
                    return false
                }
            }
        }
        return true
    }
    
    /// Returns the vertices stored in the graph.
    public var vertices: Set<Vertex> {
        return Set(nodes.keys)
    }
    
    /// Returns the edges stored in the graph.
    public var edges: [Edge] {
        var edges = [Edge]()
        for node in nodes.values {
            edges += node.edges
        }
        return edges
    }
    
    /// Returns `true` if the graph contains the given vertex.
    public func containsVertex(_ vertex: Vertex) -> Bool {
        return nodes[vertex] != nil
    }
    
    /// Returns `true` if the graph contains an edge from `source` to `destination`.
    /// Subscript notation is preferred.
    public func containsEdgeFrom(_ source: Vertex, to destination: Vertex) -> Bool {
        return edgeFrom(source, to: destination) != nil
    }
    
    /// Returns the edge connecting `source` to `destination` if it exists.
    /// Subscript notation is preferred.
    public func edgeFrom(_ source: Vertex, to destination: Vertex) -> Edge? {
        if let sourceNode = nodes[source], let destinationNode = nodes[destination] {
            return sourceNode.edgeConnectingTo(destinationNode)
        }
        return nil
    }
    
    /// Returns the set of direct successors of the given vertex. An empty set
    /// is returned if the vertex does not exist.
    public func neighbors(_ source: Vertex) -> Set<Vertex> {
        if let node = nodes[source] {
            return Set(node.successors.map{$0.data})
        }
        return []
    }
    
    /// Returns an array of vertices representing a path from `source` to `destination`, if it exists.
    ///
    /// - returns: An array containing at least two vertices (`source` and `destination`) or nil.
    public func pathFrom(_ source: Vertex, to destination: Vertex) -> [Vertex]? {
        if let sourceNode = nodes[source], let destinationNode = nodes[destination]  {
            var path = [Vertex]()
            var visited = Set<GraphNode>()
            for successor in sourceNode.successors {
                if containsPathFrom(successor, to: destinationNode, visited: &visited, path: &path) {
                    return [source] + path
                }
            }
            if !path.isEmpty {
                return path
            }
        }
        return nil
    }
    
    /// Returns a generator iterating over the vertices in the specified order starting at the given vertex.
    /// Valid options are .DepthFirst and .BreadthFirst.
    ///
    /// The generator never returns the same vertex more than once.
    public func generateAt(_ source: Vertex, order: GraphTraversalOrder) -> AnyIterator<Vertex> {
        if let sourceNode = nodes[source] {
            let nextNode: () -> GraphNode?
            let visitEventually: (GraphNode) -> Void
            switch order {
            case .depthFirst:
                var nextVertices = Stack<GraphNode>()
                nextNode = {nextVertices.isEmpty ? nil : nextVertices.pop()}
                visitEventually = {nextVertices.push($0)}
            case .breadthFirst:
                var nextVertices = Queue<GraphNode>()
                nextNode = {nextVertices.isEmpty ? nil : nextVertices.dequeue()}
                visitEventually = {nextVertices.enqueue($0)}
            }
            return vertexGenerator(sourceNode, nextNode: nextNode, visitEventually: visitEventually)
        }
        return  AnyIterator(EmptyIterator())
    }
    
    // MARK: Adding and Removing Elements
    
    // Gets, sets, or deletes an edge between vertices.
    // The vertices are inserted if they don´t exist in the graph, except when removing.
    public subscript(source: Vertex, destination: Vertex) -> Edge? {
        get {
            return edgeFrom(source, to: destination)
        }
        set {
            if let newValue = newValue {
                insertEdge(newValue, from: source, to: destination)
            } else {
                removeEdgeFrom(source, to: destination)
            }
        }
    }
    
    /// Inserts the given vertex to the graph if it doesn't exist.
    public mutating func insertVertex(_ vertex: Vertex) {
        if !containsVertex(vertex) {
            copyMyself()
            nodes[vertex] = GraphNode(vertex)
        }
    }
    
    /// Removes and returns the given vertex from the graph if it was present.
    @discardableResult
    public mutating func removeVertex(_ vertex : Vertex) -> Vertex? {
        if containsVertex(vertex) {
            copyMyself()
            let value = nodes.removeValue(forKey: vertex)?.data
            for other in nodes.keys {
                removeEdgeFrom(other, to: vertex)
            }
            return value
        }
        return nil
    }
    
    /// Connects two vertices with the given edge. If an edge already exists, it is replaced.
    /// Subscript notation is preferred.
    public mutating func insertEdge(_ edge: Edge, from source: Vertex, to destination: Vertex) {
        if source == destination {
            fatalError("Simple graphs can't have edges connected at both ends to the same vertex.")
        }
        copyMyself()
        insertVertex(source)
        insertVertex(destination)
        removeEdgeFrom(source, to: destination)
        nodes[source]?.connectTo(nodes[destination]!, withEdge: edge)
    }
    
    /// Removes and returns the edge connecting the given vertices if it exists.
    @discardableResult
    public mutating func removeEdgeFrom(_ source: Vertex, to destination: Vertex) -> Edge? {
        if containsVertex(source) && containsVertex(destination) {
            copyMyself()
            return nodes[source]!.removeConnectionTo(nodes[destination]!)
        }
        return nil
    }
    
    /// Removes all vertices and edges from the graph, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepingCapacity keep: Bool = false) {
        nodes.removeAll(keepingCapacity: keep)
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Adjacency lists graph representation.
    fileprivate var nodes = [Vertex: GraphNode]()
    
    
    /// Unique identifier to perform copy-on-write.
    fileprivate var tag = Tag()
    
    
    /// Finds a path from `source` to `destination` recursively.
    fileprivate func containsPathFrom(_ source: GraphNode, to destination: GraphNode, visited: inout Set<GraphNode> , path: inout [Vertex]) -> Bool {
        if visited.contains(source) {
            return false
        }
        visited.insert(source)
        path.append(source.data)
        if source == destination {
            return true
        }
        for vertex in source.successors {
            if containsPathFrom(vertex, to: destination, visited: &visited, path: &path) {
                return true
            }
        }
        path.removeLast()
        return false
    }
    
    /// Returns a generator over the vertices starting at the given node.
    /// The generator never returns the same vertex twice.
    /// Using nextVertex and visitEventually allows you to specify the order of traversal.
    ///
    /// - parameter source: The first node to visit.
    /// - parameter nextNode: Returns the next node to visit.
    /// - parameter visitEventually: Gives a neighbor of the vertex previously returned by nextNode().
    fileprivate func vertexGenerator(_ source: GraphNode, nextNode:@escaping () -> GraphNode?, visitEventually: @escaping (GraphNode)->Void) -> AnyIterator<Vertex> {
        var visited = Set<GraphNode>()
        visitEventually(source)
        return AnyIterator {
            if let next = nextNode() {
                visited.insert(next)
                for successor in next.successors {
                    if !visited.contains(successor) {
                        visitEventually(successor)
                    }
                }
                return next.data
            }
            return nil
        }
    }
    
    /// Creates a new copy of the nodes in the graph if there´s
    /// more than one strong reference pointing the graph's tag.
    ///
    /// The Graph itself is a value type but a VertexNode is a reference type,
    /// calling this method ensures copy-on-write behavior.
    fileprivate mutating func copyMyself() {
        if !isKnownUniquelyReferenced(&tag) {
            tag = Tag()
            var newNodes = [Vertex: GraphNode]()
            for vertex in nodes.keys {
                newNodes[vertex] = GraphNode(vertex)
            }
            for (vertex, oldNode) in nodes {
                let newNode = newNodes[vertex]!
                
                let edges = Array(oldNode.edges)
                let successors = oldNode.successors.map{newNodes[$0.data]!}
                for (index, successor) in successors.enumerated() {
                    newNode.connectTo(successor, withEdge: edges[index])
                }
            }
            nodes = newNodes
        }
    }
}

extension Graph: Sequence {
    
    // MARK: Sequence Protocol Conformance
    
    /// Provides for-in loop functionality.
    ///
    /// - returns: A generator over the vertices.
    public func makeIterator() -> AnyIterator<Vertex> {
        return AnyIterator(nodes.keys.makeIterator())
    }
}

// MARK: - Operators

// MARK: Graph Operators

/// Returns `true` if and only if the graphs contain the same vertices and edges per vertex.
/// The underlying edges must conform to the `Equatable` protocol.
public func ==<V, E: Equatable>(lhs: Graph<V,E>, rhs: Graph<V,E>) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for (vertex, lNode) in lhs.nodes {
        if rhs.nodes[vertex] == nil {
            return false
        }
        let rNode = rhs.nodes[vertex]!
        if lNode.adjacencyList.count != rNode.adjacencyList.count {
            return false
        }
        let containsAllEdges = !lNode.successors.contains {
            rNode.edgeConnectingTo($0) != lNode.edgeConnectingTo($0)
        }
        if !containsAllEdges {
            return false
        }
    }
    return true
}

public func !=<V, E: Equatable>(lhs: Graph<V,E>, rhs: Graph<V,E>) -> Bool {
    return !(lhs == rhs)
}

// MARK: - GraphTraversalOrder

public enum GraphTraversalOrder {
    case depthFirst
    case breadthFirst
}

// MARK: - VertexNode

private class VertexNode<V: Hashable, E>: Hashable {
    
    typealias Bridge = (destination: VertexNode<V,E>, edge: E)
    
    let data : V
    var adjacencyList = [Bridge]()
    
    var successors: AnyCollection<VertexNode<V, E>> {
        return AnyCollection(adjacencyList.lazy.map {$0.destination})
    }
    
    var edges: AnyCollection<E> {
        return AnyCollection(adjacencyList.lazy.map {$0.edge})
    }
    
    var hashValue: Int {
        return data.hashValue
    }
    
    init(_ vertex: V) {
        self.data = vertex
    }
    
    func connectTo(_ vertex: VertexNode, withEdge edge: E) {
        adjacencyList.append((vertex, edge))
    }
    
    func edgeConnectingTo(_ vertex: VertexNode) -> E? {
        for neighbor in adjacencyList {
            if neighbor.destination == vertex {
                return neighbor.edge
            }
        }
        return nil
    }
    
    func removeConnectionTo(_ vertex: VertexNode) -> E? {
        for (index, neighbor) in adjacencyList.enumerated() {
            if neighbor.destination == vertex {
                return adjacencyList.remove(at: index).edge
            }
        }
        return nil
    }
}

private func ==<V, E>(lhs: VertexNode<V, E>, rhs: VertexNode<V, E>) -> Bool {
    return lhs.data == rhs.data
}

// MARK: - Tag

private class Tag {}
