//
//  DequeTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 3/26/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class DequeTests: XCTestCase {

    struct TestData {
        static let Value = 50
        static let List = [Int](1...10)
    }
    
    var deque = Deque<Int>()
    
    func testEmptyDeque() {
        XCTAssertEqual(deque.count, 0)
        XCTAssertNil(deque.first)
        XCTAssertNil(deque.last)
    }
    
    func testInitWithArray() {
        deque = Deque(TestData.List)
        for i in 0..<TestData.List.count {
            let element = deque.dequeueFirst()
            XCTAssertNotNil(element)
            XCTAssertEqual(element!, TestData.List[i])
        }
    }
    
    func testSingleEnqueueFirst() {
        deque.enqueueFirst(TestData.Value)
        XCTAssertEqual(deque.count, 1)
        XCTAssertTrue(deque.first != nil && deque.first! == TestData.Value)
        XCTAssertTrue(deque.last != nil && deque.last! == TestData.Value)
    }
    
    func testConsecutiveEnqueueFirst() {
        for i in TestData.List {
            deque.enqueueFirst(i)
        }
        let reverseList = reverse(TestData.List)
        XCTAssertEqual(deque.count, TestData.List.count)
        for i in 0..<TestData.List.count {
            let element = deque.dequeueFirst()
            XCTAssertNotNil(element)
            XCTAssertEqual(element!, reverseList[i])
        }
    }
    
    func testEmptyDequeueFirst() {
        XCTAssertNil(deque.dequeueFirst())
    }
    
    func testSingleEnqueueLast() {
        deque.enqueueLast(TestData.Value)
        XCTAssertEqual(deque.count, 1)
        XCTAssertTrue(deque.first != nil && deque.first! == TestData.Value)
        XCTAssertTrue(deque.last != nil && deque.last! == TestData.Value)
    }
    
    func testConsecutiveEnqueueLast() {
        for i in TestData.List {
            deque.enqueueLast(i)
        }
        XCTAssertEqual(deque.count, TestData.List.count)
        for i in 0..<TestData.List.count {
            let element = deque.dequeueFirst()
            XCTAssertNotNil(element)
            XCTAssertEqual(element!, TestData.List[i])
        }
    }
    
    func testRemoveAll() {
        deque = Deque(TestData.List)
        deque.removeAll(keepCapacity: true)
        XCTAssertEqual(deque.count, 0)
        XCTAssertNil(deque.dequeueFirst())
        XCTAssertNil(deque.dequeueLast())
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        deque = Deque(TestData.List)
        XCTAssertTrue(equal(deque, TestData.List))
    }
    
    // MARK: ArrayLiteralConvertible
    
    func testArrayLiteralConvertibleConformance() {
        deque = [1,2,3]
        XCTAssertTrue(equal(deque, [1,2,3]))
    }
    
    // MARK: Operators
    
    func testEqual() {
        deque = []
        var other: Deque<Int>  = []
        XCTAssertTrue(deque == other)
        deque = [TestData.Value]
        XCTAssertFalse(deque == other)
        other.enqueueLast(TestData.Value)
        XCTAssertTrue(deque == other)
    }
    
}
