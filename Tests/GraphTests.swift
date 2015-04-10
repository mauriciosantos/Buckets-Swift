//
//  GraphTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/9/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class GraphTests: XCTestCase {

    var graph = Graph<String, Int>()
    
    func testEmptyGraph() {
        XCTAssertEqual(graph.count, 0)
        XCTAssertEqual(graph.edges, [])
        XCTAssertEqual(graph.vertices, [])
        XCTAssertTrue(graph.isAcyclic)
        XCTAssertTrue(graph.isComplete)
    }
    
    func testCount() {
        graph["NY", "Miami"] = 1
        graph["NY", "Toronto"] = 1
        XCTAssertEqual(graph.count, 3)
    }
    
    func testVertices() {
        graph["NY", "Miami"] = 1
        XCTAssertEqual(Set(graph.vertices), Set(["NY", "Miami"]))
    }
    
    func testEdges() {
        graph["NY", "Miami"] = 1
        graph["NY", "Toronto"] = 1
        XCTAssertEqual(graph.edges, [1,1])
    }
    
    func testIsAcyclic() {
        graph["NY", "Miami"] = 1
        graph["Miami", "Toronto"] = 1
        XCTAssertTrue(graph.isAcyclic)
        graph["Toronto", "Miami"] = 2
        XCTAssertFalse(graph.isAcyclic)
    }
    
    func testIsComplete() {
        graph["NY", "Miami"] = 1
        XCTAssertFalse(graph.isComplete)
        graph["NY", "Toronto"] = 1
        XCTAssertFalse(graph.isComplete)
        graph["Toronto", "Miami"] = 2
        XCTAssertFalse(graph.isComplete)
        graph["Miami", "Toronto"] = 2
        graph["Miami", "NY"] = 2
        graph["Toronto", "NY"] = 2
        XCTAssertTrue(graph.isComplete)
    }
    
    func testEmptyContainsVertex() {
        XCTAssertFalse(graph.containsVertex("NY"))
    }
    
    func testNonEmptyContainsVertex() {
        graph["NY", "Miami"] = 10
        XCTAssertTrue(graph.containsVertex("NY"))
        XCTAssertTrue(graph.containsVertex("Miami"))
    }
    
    func testContainsEdgeFromTo() {
        graph["NY", "Miami"] = 1
        graph["Miami", "Toronto"] = 1
        XCTAssertTrue(graph.containsEdgeFrom("NY", to: "Miami"))
        XCTAssertFalse(graph.containsEdgeFrom("Miami", to: "NY"))
        XCTAssertFalse(graph.containsEdgeFrom("NY", to: "Toronto"))
    }
    
    func testEdgeFromTo() {
        graph["NY", "Miami"] = 2
        graph["Miami", "Toronto"] = 1
        XCTAssertNotNil(graph.edgeFrom("NY", to: "Miami"))
        XCTAssertEqual(graph.edgeFrom("NY", to: "Miami")!, 2)
        XCTAssertNil(graph.edgeFrom("NY", to: "Toronto"))
    }
    
    func testNeighbors() {
        graph["NY", "Miami"] = 1
        graph["NY", "Boston"] = 1
        graph.insertVertex("LA")
        XCTAssertEqual(graph.neighbors("LA"), [])
        XCTAssertEqual(graph.neighbors("NY"), ["Miami", "Boston"])
        XCTAssertEqual(graph.neighbors("Miami"), [])
    }
    
    func testEmptyPathFromTo() {
        graph["NY", "Miami"] = 1
        graph["Miami", "Boston"] = 1
        graph["Boston", "La"] = 1
        XCTAssertEqual(graph.pathFrom("Boston", to: "NY"), [])
    }
    
    func testExistingPathFromTo() {
        graph["NY", "Miami"] = 1
        graph["Miami", "Boston"] = 1
        graph["Miami", "Vancouver"] = 1
        graph["Boston", "LA"] = 1
        XCTAssertEqual(graph.pathFrom("NY", to: "LA"), ["NY", "Miami", "Boston", "LA"])
    }
    
    func testCyclicPathFromTo() {
        graph["NY", "Miami"] = 1
        graph["Miami", "NY"] = 1
        XCTAssertEqual(graph.pathFrom("NY", to: "NY"), ["NY", "Miami", "NY"])
    }
    
    func testGenerateDepthFirstAt() {
        graph["NY", "Miami"] = 1
        graph["Miami", "Boston"] = 1
        graph["Miami", "Vancouver"] = 1
        graph["Boston", "LA"] = 1
        var visited = Set<String>()
        for vertex in graph.generateAt("NY", order: .DepthFirst) {
            if visited.contains(vertex) {
                XCTFail()
            }
            visited.insert(vertex)
        }
        XCTAssertEqual(graph.vertices, visited)
    }
    
    func testGenerateBreadthFirstAt() {
        graph["NY", "Miami"] = 1
        graph["Miami", "Boston"] = 1
        graph["Miami", "Vancouver"] = 1
        graph["Boston", "LA"] = 1
        var visited = Set<String>()
        for vertex in graph.generateAt("NY", order: .BreadthFirst) {
            if visited.contains(vertex) {
                XCTFail()
            }
            visited.insert(vertex)
        }
        XCTAssertEqual(graph.vertices, visited)
    }
    
    func testInsertVertex() {
        graph.insertVertex("NY")
        graph.insertVertex("Boston")
        XCTAssertEqual(graph.count, 2)
        XCTAssertTrue(graph.containsVertex("NY"))
        XCTAssertTrue(graph.containsVertex("Boston"))
    }
    
    func testRemoveVertex() {
        graph["NY", "Miami"] = 1
        graph["Miami", "Boston"] = 1
        XCTAssertNotNil(graph.removeVertex("Miami"))
        XCTAssertFalse(graph.containsVertex("Miami"))
        XCTAssertTrue(graph.containsVertex("NY"))
        XCTAssertTrue(graph.containsVertex("Boston"))
        XCTAssertNil(graph.removeVertex("LA"))
        XCTAssertEqual(graph.count, 2)
    }
    
    func testInsertEdge() {
        graph.insertEdge(1, from: "Miami", to: "Boston")
        XCTAssertEqual(graph["Miami", "Boston"]!, 1)
        XCTAssertEqual(graph.count, 2)
    }
    
    func testRemoveEdge() {
        graph.insertEdge(1, from: "Miami", to: "Boston")
        XCTAssertEqual(graph.removeEdgeFrom("Miami", to: "Boston")!, 1)
        XCTAssertNil(graph["Miami", "Boston"])
        XCTAssertEqual(graph.edges, [])
    }
    
    func testRemoveAll() {
        graph["NY", "Miami"] = 1
        graph["Miami", "Boston"] = 1
        graph.removeAll(keepCapacity: true)
        XCTAssertEqual(graph.vertices, [])
    }

}
