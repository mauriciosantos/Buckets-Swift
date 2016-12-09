//
//  StackTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 3/26/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class StackTests: XCTestCase {
    
    struct TestData {
        static let Value = 50
        static let List = [Int](1...10)
    }
    
    var stack = Stack<Int>()
    
    func testEmptyStack() {
        XCTAssertEqual(stack.count, 0)
        XCTAssertNil(stack.top)
    }
    
    func testInitWithArray() {
        stack = Stack(TestData.List)
        let list = Array(TestData.List.reversed())
        for i in 0..<list.count {
            let element = stack.pop()
            XCTAssertNotNil(element)
            XCTAssertEqual(element, list[i])
        }
    }
    
    func testSinglePush() {
        stack.push(TestData.Value)
        XCTAssertEqual(stack.count, 1)
        XCTAssertTrue(stack.top != nil && stack.top! == TestData.Value)
    }
    
    func testConsecutivePush() {
        for i in TestData.List {
            stack.push(i)
        }
        XCTAssertEqual(stack.count, TestData.List.count)
        let list = Array(TestData.List.reversed())
        for i in 0..<list.count {
            let element = stack.pop()
            XCTAssertNotNil(element)
            XCTAssertEqual(element, list[i])
        }
        XCTAssertNil(stack.top)
    }
    
    func testRemoveAll() {
        stack = Stack(TestData.List)
        stack.removeAll(keepingCapacity: true)
        XCTAssertEqual(stack.count, 0)
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        stack = Stack(TestData.List)
        XCTAssertTrue(stack.elementsEqual(Array(TestData.List.reversed())))
    }
    
    // MARK: ArrayLiteralConvertible
    
    func testArrayLiteralConvertibleConformance() {
        stack = [1,2,3]
        XCTAssertTrue(stack.elementsEqual([3,2,1]))
    }
    
    // MARK: Operators
    
    func testEqual() {
        stack = []
        var other: Stack<Int>  = []
        XCTAssertTrue(stack == other)
        stack = [TestData.Value]
        XCTAssertFalse(stack == other)
        other.push(TestData.Value)
        XCTAssertTrue(stack == other)
    }

}
