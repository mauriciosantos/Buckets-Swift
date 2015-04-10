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
/// All vertices in the graph are unique.
/// The preferred  way to insert vertices and edges is using subscript notation. Example:
/// `graph["NY", "Boston"] = distance"
///
/// Conforms to `SequenceType`.
public struct Graph<Vertex: Hashable, Edge> {
    
    private typealias GraphNode = VertexNode<Vertex, Edge>
    
    // MARK: Creating a Graph
    
    /// Creates an empty graph.
    public init() {}
    
    
    // MARK: Querying a Graph
    
    /// Number of vertices stored in the graph.
    public var count: Int  {
        return nodes.count
    }
    
    /// `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// Returns `true` if every pair of distinct vertices is connected by a 
    /// unique edge (one in each direction).
    public var isComplete: Bool {
        return !contains(nodes.values) { $0.successors.count != count - 1 }
    }
    
    /// Returns `true` if there's not a path starting and ending 
    /// at the same vertex.
    public var isAcyclic: Bool {
        for source in nodes.keys {
            if !pathFrom(source, to: source).isEmpty {
                return false
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
    public func containsVertex(vertex: Vertex) -> Bool {
        return nodes[vertex] != nil
    }
    
    /// Returns `true` if the graph contains an edge from `source` to `destination`.
    /// Subscript notation is preferred.
    public func containsEdgeFrom(source: Vertex, to destination: Vertex) -> Bool {
        return edgeFrom(source, to: destination) != nil
    }
    
    /// Returns the edge connecting `source` to `destination` if it exists.
    /// Subscript notation is preferred.
    public func edgeFrom(source: Vertex, to destination: Vertex) -> Edge? {
        if let sourceNode = nodes[source], destinationNode = nodes[destination] {
            return sourceNode.edgeConnectingTo(destinationNode)
        }
        return nil
    }
    
    /// Returns the set of direct successors of the given vertex. An empty set
    /// is returned if the vertex does not exist.
    public func neighbors(source: Vertex) -> Set<Vertex> {
        if let node = nodes[source] {
            return Set(lazy(node.successors).map{$0.data})
        }
        return []
    }
    
    /// Returns an array of vertices representing a path from `source` to `destination`, if it exists.
    ///
    /// :returns: An array with at least two vertices (`source` and `destination`) or an empty array.
    public func pathFrom(source: Vertex, to destination: Vertex) -> [Vertex] {
        if containsVertex(source) && containsVertex(destination) {
            var path = [Vertex]()
            var visited = Set<Vertex>()
            for vertex in neighbors(source) {
                if containsPathFrom(vertex, to: destination, visited: &visited, path: &path) {
                    return [source] + path
                }
            }
        }
        return []
    }
    
    /// Returns a generator iterating over the vertices in the specified order starting at the given vertex.
    /// Valid options are .DepthFirst and .BreadthFirst.
    ///
    /// The generator never returns the same vertex more than once.
    public func generateAt(source: Vertex, order: GraphTraversalOrder) -> GeneratorOf<Vertex> {
        let nextVertex: () -> Vertex?
        let visitEventually: (Vertex) -> Void
        switch order {
            case .DepthFirst:
                var nextVertices = Stack<Vertex>()
                nextVertex = {nextVertices.pop()}
                visitEventually = {nextVertices.push($0)}
            case .BreadthFirst:
                var nextVertices = Queue<Vertex>()
                nextVertex = {nextVertices.dequeue()}
                visitEventually = {nextVertices.enqueue($0)}
        }
        return vertexGenerator(source, nextVertex: nextVertex, visitEventually: visitEventually)
    }
    
    // MARK: Adding and Removing Elements
    
    /// Gets, sets, or deletes an edge between vertices.
    /// The vertices are inserted if they don´t exist in the graph, except when removing.
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
    public mutating func insertVertex(vertex: Vertex) {
        if !containsVertex(vertex) {
            copyMyself()
            nodes[vertex] = GraphNode(vertex)
        }
    }
    
    /// Removes and returns the given vertex from the graph if it was present.
    public mutating func removeVertex(vertex : Vertex) -> Vertex? {
        if containsVertex(vertex) {
            copyMyself()
            let value = nodes.removeValueForKey(vertex)?.data
            for other in nodes.keys {
                removeEdgeFrom(other, to: vertex)
            }
            return value
        }
        return nil
    }
    
    /// Connects two vertices with the given edge. If an edge already exists, it is replaced.
    /// Subscript notation is preferred.
    public mutating func insertEdge(edge: Edge, from source: Vertex, to destination: Vertex) {
        if source == destination {
            fatalError("Simple Graph can't have edges connected at both ends to the same vertex")
        }
        copyMyself()
        insertVertex(source)
        insertVertex(destination)
        removeEdgeFrom(source, to: destination)
        nodes[source]?.connectTo(nodes[destination]!, withEdge: edge)
    }
    
    /// Removes and returns the edge connecting the given vertices if it exists.
    public mutating func removeEdgeFrom(source: Vertex, to destination: Vertex) -> Edge? {
        if containsVertex(source) && containsVertex(destination) {
            copyMyself()
            return nodes[source]!.removeConnectionTo(nodes[destination]!)
        }
        return nil
    }
    
    /// Removes all vertices and edges from the graph, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true) {
        nodes.removeAll(keepCapacity: keep)
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Adjacency lists graph representation.
    private var nodes = [Vertex: GraphNode]()
    
    
    /// Unique identifier to perform copy-on-write.
    private var tag = Tag()
    
    
    /// Finds a path from `source` to `destination` recursively.
    private func containsPathFrom(source: Vertex, to destination: Vertex,
        inout visited: Set<Vertex> , inout path: [Vertex]) -> Bool {
            if visited.contains(source) {
                return false
            }
            visited.insert(source)
            path.append(source)
            if source == destination {
                return true
            }
            for vertex in neighbors(source) {
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
    /// :param: source The first node to visit.
    /// :param: nextVertex Returns the next node to visit. 
    /// :param: visitEventually Gives a neighbor of the vertex previously returned by nextVertex().
    private func vertexGenerator(source: Vertex, nextVertex:() -> Vertex?, visitEventually: (Vertex)->Void) -> GeneratorOf<Vertex> {
        var visited = Set<Vertex>()
        visitEventually(source)
        return GeneratorOf {
            if let next = nextVertex() {
                visited.insert(next)
                for neighbor in self.neighbors(next) {
                    if !visited.contains(neighbor) {
                        visitEventually(neighbor)
                    }
                }
                return next
            }
            return nil
        }
    }
    
    /// Creates a new copy of the nodes in the graph if there´s
    /// more than one strong reference pointing the graph's tag.
    ///
    /// The Graph itself is a value type but a VertexNode is a reference type,
    /// calling this method ensures copy-on-write behavior.
    private mutating func copyMyself() {
        if !isUniquelyReferencedNonObjC(&tag) {
            tag = Tag()
            var newNodes = [Vertex: GraphNode]()
            for vertex in nodes.keys {
                newNodes[vertex] = GraphNode(vertex)
            }
            for (vertex, oldNode) in nodes {
                let newNode = newNodes[vertex]!
                
                let edges = oldNode.edges
                let successors = lazy(oldNode.successors).map{newNodes[$0.data]!}
                for (index, successor) in enumerate(successors) {
                    newNode.connectTo(successor, withEdge: edges[index])
                }
            }
            nodes = newNodes
        }
    }
}

// MARK: - Extenstions

extension Graph: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality.
    ///
    /// :returns: A generator over the vertices.
    public func generate() -> GeneratorOf<Vertex> {
        return GeneratorOf(nodes.keys.generate())
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
        if let rNode = rhs.nodes[vertex] where lNode.adjacencyList.count != rNode.adjacencyList.count
            && rNode.successors == lNode.successors {
                
                let lEdges = lNode.edges
                var rEdges = rNode.edges
                
                for edge in lEdges {
                    if let index = find(rEdges, edge) {
                        rEdges.removeAtIndex(index)
                    }
                }
        } else {
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
    case DepthFirst
    case BreadthFirst
}

// MARK: - VertexNode

private class VertexNode<V: Hashable, E>: Hashable {
    
    typealias Bridge = (destination: VertexNode<V,E>, edge: E)
    
    let data : V
    var adjacencyList = [Bridge]()
    
    var successors: [VertexNode<V,E>] {
        return adjacencyList.map{$0.destination}
    }
    
    var edges: [E] {
        return adjacencyList.map{$0.edge}
    }
    
    var hashValue: Int {
        return data.hashValue
    }
    
    init(_ vertex: V) {
        self.data = vertex
    }
    
    func connectTo(vertex: VertexNode, withEdge edge: E) {
        adjacencyList.append((vertex, edge))
    }
    
    func edgeConnectingTo(vertex: VertexNode) -> E? {
        for neighbor in adjacencyList {
            if neighbor.destination == vertex {
                return neighbor.edge
            }
        }
        return nil
    }
    
    func removeConnectionTo(vertex: VertexNode) -> E? {
        for (index, neighbor) in enumerate(adjacencyList) {
            if neighbor.destination == vertex {
                return adjacencyList.removeAtIndex(index).edge
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
