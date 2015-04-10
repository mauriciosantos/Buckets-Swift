//
//  PriorityQueueTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 3/26/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class PriorityQueueTests: XCTestCase {

    struct TestData {
        static let Value = 50
        static let List = [4,5,3,3,1,2]
        static let Max = 5
    }
    
    var queue = PriorityQueue<Int>(>)
    
    func testEmptyQueue() {
        XCTAssertEqual(queue.count, 0)
        XCTAssertNil(queue.first)
    }
    
    func testInitWithArray() {
        queue = PriorityQueue(TestData.List, >)
        let list = TestData.List.sorted(>)
        for i in 0..<list.count {
            let element = queue.dequeue()
            XCTAssertNotNil(element)
            XCTAssertEqual(element!, list[i])
        }
    }
    
    func testSingleEnqueue() {
        queue.enqueue(TestData.Value)
        XCTAssertEqual(queue.count, 1)
        XCTAssertTrue(queue.first != nil && queue.first! == TestData.Value)
    }
    
    func testConsecutiveEnqueues() {
        for i in TestData.List {
            queue.enqueue(i)
        }
        XCTAssertEqual(queue.count, TestData.List.count)
        let list = TestData.List.sorted(>)
        for i in 0..<list.count {
            let element = queue.dequeue()
            XCTAssertNotNil(element)
            XCTAssertEqual(element!, list[i])
        }
        XCTAssertNil(queue.dequeue())
        XCTAssertNil(queue.first)
    }
    
    func testEmptyDequeue() {
        XCTAssertNil(queue.dequeue())
        XCTAssertNil(queue.first)
    }
    
    func testRemoveAll() {
        queue = PriorityQueue(TestData.List, >)
        queue.removeAll(keepCapacity: true)
        XCTAssertEqual(queue.count, 0)
        XCTAssertNil(queue.dequeue())
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        queue = PriorityQueue(TestData.List, >)
        var list = TestData.List
        for element in queue {
            if let index = find(list, element) {
                list.removeAtIndex(index)
            }
        }
        XCTAssertEqual(list.count, 0)
    }
    
    // MARK: Operators
    
    func testEqual() {
        queue = PriorityQueue<Int>(>)
        var other = PriorityQueue<Int>(>)
        XCTAssertTrue(queue == other)
        queue.enqueue(TestData.Value)
        XCTAssertFalse(queue == other)
        other.enqueue(TestData.Value)
        XCTAssertTrue(queue == other)
    }
    
}
