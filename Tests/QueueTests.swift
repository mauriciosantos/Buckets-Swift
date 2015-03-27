//
//  QueueTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 3/26/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class QueueTests: XCTestCase {

    struct TestData {
        static let Value = 50
        static let List = [Int](1...10)
    }
    
    var queue = Queue<Int>()
    
    func testEmptyQueue() {
        XCTAssertEqual(queue.count, 0)
        XCTAssertNil(queue.first)
    }
    
    func testInitWithArray() {
        queue = Queue(elements: TestData.List)
        for i in 0..<TestData.List.count {
            let element = queue.dequeue()
            XCTAssertNotNil(element)
            XCTAssertEqual(element!, TestData.List[i])
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
        for i in 0..<TestData.List.count {
            let element = queue.dequeue()
            XCTAssertNotNil(element)
            XCTAssertEqual(element!, TestData.List[i])
        }
        XCTAssertNil(queue.dequeue())
        XCTAssertNil(queue.first)
    }
    
    func testEmptyDequeue() {
        XCTAssertNil(queue.dequeue())
        XCTAssertNil(queue.first)
    }
    
    func testRemoveAll() {
        queue = Queue(elements: TestData.List)
        queue.removeAll(keepCapacity: true)
        XCTAssertEqual(queue.count, 0)
        XCTAssertNil(queue.dequeue())
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        queue = Queue(elements: TestData.List)
        XCTAssertTrue(equal(queue, TestData.List))
    }
    
    // MARK: ArrayLiteralConvertible
    
    func testArrayLiteralConvertibleConformance() {
        queue = [1,2,3]
        XCTAssertTrue(equal(queue, [1,2,3]))
    }
    
    // MARK: Operators
    
    func testEqual() {
        queue = []
        var other: Queue<Int>  = []
        XCTAssertTrue(queue == other)
        queue = [TestData.Value]
        XCTAssertFalse(queue == other)
        other.enqueue(TestData.Value)
        XCTAssertTrue(queue == other)
    }
}
