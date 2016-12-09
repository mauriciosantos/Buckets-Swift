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
    
    var queue = PriorityQueue<Int>(sortedBy: >)
    
    func testEmptyQueue() {
        XCTAssertEqual(queue.count, 0)
        XCTAssertNil(queue.first)
    }
    
    func testInitWithArray() {
        queue = PriorityQueue(TestData.List, sortedBy: >)
        let list = TestData.List.sorted(by: >)
        for i in 0..<list.count {
            let element = queue.dequeue()
            XCTAssertNotNil(element)
            XCTAssertEqual(element, list[i])
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
        let list = TestData.List.sorted(by: >)
        for i in 0..<list.count {
            let element = queue.dequeue()
            XCTAssertNotNil(element)
            XCTAssertEqual(element, list[i])
        }
    }
    
    func testRemoveAll() {
        queue = PriorityQueue(TestData.List, sortedBy: >)
        queue.removeAll(keepingCapacity: true)
        XCTAssertEqual(queue.count, 0)
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        queue = PriorityQueue(TestData.List, sortedBy: >)
        var list = TestData.List
        for element in queue {
            if let index = list.index(of: element) {
                list.remove(at: index)
            }
        }
        XCTAssertEqual(list.count, 0)
    }
    
    // MARK: Operators
    
    func testEqual() {
        queue = PriorityQueue<Int>(sortedBy: >)
        var other = PriorityQueue<Int>(sortedBy: >)
        XCTAssertTrue(queue == other)
        queue.enqueue(TestData.Value)
        XCTAssertFalse(queue == other)
        other.enqueue(TestData.Value)
        XCTAssertTrue(queue == other)
    }
    
}
