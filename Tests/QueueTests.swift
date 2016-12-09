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
        queue = Queue(TestData.List)
        for i in 0..<TestData.List.count {
            let element = queue.dequeue()
            XCTAssertNotNil(element)
            XCTAssertEqual(element, TestData.List[i])
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
            XCTAssertEqual(element, TestData.List[i])
        }
    }
    
    func testRemoveAll() {
        queue = Queue(TestData.List)
        queue.removeAll(keepingCapacity: true)
        XCTAssertEqual(queue.count, 0)
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        queue = Queue(TestData.List)
        XCTAssertTrue(queue.elementsEqual(TestData.List))
    }
    
    // MARK: ArrayLiteralConvertible
    
    func testArrayLiteralConvertibleConformance() {
        queue = [1,2,3]
        XCTAssertTrue(queue.elementsEqual([1,2,3]))
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
