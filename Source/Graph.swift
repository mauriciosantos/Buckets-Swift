////
////  Graph.swift
////  Buckets
////
////  Created by Mauricio Santos on 2/19/15.
////  Copyright (c) 2015 Mauricio Santos. All rights reserved.
////
//
//import Foundation
//
//private struct Edge<V, E> {
//    private let origin: V
//    private let destination: V
//    private let data: E
//}
//
//public struct Graph<V: Hashable, E> {
//
//    private var adjacencyLists = [V: [Edge<V,E>]]()
//    
//    // Ugly! abusing HeapBuffer purely to detect unique references an copy on write
//    private var tag = HeapBuffer<Int,Int>(HeapBuffer<Int,Int>.Storage.self, 1, 0)
//    
//    public mutating func insertVertex(vertex: V) {
//        if adjacencyLists[vertex] != nil {
//            adjacencyLists[vertex] = [Edge<V,E>]()
//        }
//    }
//    
//    // Origin and destination are inserted to the graph if they are not present already   
//    public mutating func insertEdgeFrom(origin o: V, destination d: V, edgeData e: E) {
//        insertVertex(o)
//        insertVertex(d)
//        adjacencyLists[o]?.append(Edge(origin: o, destination: d, data: e))
//    }
//    
//    public mutating func removeVertex(vertex : V) {
//        adjacencyLists.removeValueForKey(vertex)
//        let lists = adjacencyLists
//        for (vertex, edges) in lists {
//            var newEdges = [Edge<V,E>]()
//            for edge in edges {
//                if edge.destination != vertex {
//                    newEdges.append(edge)
//                }
//            }
//            adjacencyLists[vertex] = newEdges
//        }
//    }
//    
//    public func containsVertex(vertex: V) -> Bool {
//        return adjacencyLists[vertex] != nil
//    }
//    
//    public func containsEdgeFrom(from: V, to: V) -> Bool {
//        if let edges = adjacencyLists[from] {
//            for edge in edges {
//                if edge.destination == to {
//                    return true
//                }
//            }
//        }
//        return false
//    }
//}
//