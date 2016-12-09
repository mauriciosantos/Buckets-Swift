//
//  CircularArrayTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 3/13/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import XCTest
import Buckets

class CircularArrayTests: XCTestCase {
    
    struct TestData {
        static let Value = 50
        static let List = [Int](1...10)
    }
    
    var cArray = CircularArray<Int>()
    
    func testEmptyArray() {
        XCTAssertEqual(cArray.count, 0)
        XCTAssertNil(cArray.first)
        XCTAssertNil(cArray.last)
    }
    
    func testInitWithRepeatedValue() {
        let count = 30
        cArray = CircularArray(repeating: TestData.Value, count: count)
        XCTAssertEqual(cArray.count, count)
        for i in 0..<count {
            XCTAssertEqual(cArray[i], TestData.Value)
        }
    }
    
    func testSinglePrepend() {
        cArray.prepend(TestData.Value)
        XCTAssertEqual(cArray.count, 1)
        XCTAssertTrue(cArray.first != nil && cArray.first! == TestData.Value)
        XCTAssertTrue(cArray.last != nil && cArray.last! == TestData.Value)
    }
    
    func testConsecutivePrepends() {
        for i in TestData.List {
            cArray.prepend(i)
        }
        let reverseList = Array(TestData.List.reversed())
        XCTAssertEqual(cArray.count, TestData.List.count)
        for i in 0..<TestData.List.count {
            XCTAssertEqual(cArray[i], reverseList[i])
        }
    }
    
    func testSingleAppend() {
        cArray.append(TestData.Value)
        XCTAssertEqual(cArray.count, 1)
        XCTAssertTrue(cArray.first != nil && cArray.first! == TestData.Value)
        XCTAssertTrue(cArray.last != nil && cArray.last! == TestData.Value)
    }
    
    func testConsecutiveAppends() {
        for i in TestData.List {
            cArray.append(i)
        }
        
        XCTAssertEqual(cArray.count, TestData.List.count)
        for i in 0..<TestData.List.count {
            XCTAssertEqual(cArray[i], TestData.List[i])
        }
    }
    
    func testNonEmptyRemoveFirst() {
        cArray = CircularArray(TestData.List)
        let first = cArray.removeFirst()
        XCTAssertEqual(first, TestData.List.first)
        XCTAssertEqual(cArray.count, TestData.List.count - 1)
    }
    
    func testNonEmptyRemoveLast() {
        cArray = CircularArray(TestData.List)
        let last = cArray.removeLast()
        XCTAssertEqual(last, TestData.List.last)
        XCTAssertEqual(cArray.count, TestData.List.count - 1)
        XCTAssertEqual(cArray.count, TestData.List.count - 1)
    }
    
    
    func testInsertAtIndex() {
        for i in 0..<TestData.List.count {
            for j in 0...i {
                var list = [] + TestData.List[0...i]
                var array = CircularArray(list)
                list.insert(TestData.Value, at: j)
                array.insert(TestData.Value, at: j)
                XCTAssertEqual(array.count, list.count)
                XCTAssertTrue(list.elementsEqual(array))
            }
        }
    }
    
    
    func testRemoveAtIndex() {
        for i in 0..<TestData.List.count {
            for j in 0...i {
                var list = [] + TestData.List[0...i]
                var array = CircularArray(list)
                XCTAssertEqual(list.remove(at: j), array.remove(at: j))
                XCTAssertEqual(array.count, list.count)
                XCTAssertTrue(list.elementsEqual(array))
            }
        }
    }
    
    func testRemoveAll() {
        cArray = CircularArray(TestData.List)
        cArray.removeAll(keepingCapacity: true)
        XCTAssertEqual(cArray.count, 0)
    }
    
    func testAppendAfterRemoveAll() {
        cArray = CircularArray(TestData.List)
        cArray.removeAll(keepingCapacity: true)
        cArray.append(TestData.Value)
        XCTAssertTrue(cArray.first != nil && cArray.first! == TestData.Value)
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        cArray = CircularArray(TestData.List)
        XCTAssertTrue(cArray.elementsEqual(TestData.List))
    }
    
    // MARK: MutableCollectionType
    
    func testSubscriptGet() {
        for i in 0..<TestData.List.count {
            let list = [] + TestData.List[0...i]
            cArray = CircularArray(list)
            for j in 0...i {
                XCTAssertEqual(cArray[j], list[j])
            }
            XCTAssertEqual(cArray[0], cArray.first!)
            XCTAssertEqual(cArray[i], cArray.last!)
        }
    }
    
    func testSubscriptSet() {
        let reversedList = Array(TestData.List.reversed())
        cArray = CircularArray(repeating: 0, count: reversedList.count)
        for i in 0..<reversedList.count {
            cArray[i] = reversedList[i]
            XCTAssertEqual(cArray[i], reversedList[i])
        }
    }
    
    // MARK: ArrayLiteralConvertible
    
    func testArrayLiteralConvertibleConformance() {
        cArray = [1,2,3]
        XCTAssertTrue(cArray.elementsEqual([1,2,3]))
    }
    
    // MARK: Operators
    
    func testEqual() {
        cArray = []
        var other: CircularArray<Int>  = []
        XCTAssertTrue(cArray == other)
        cArray = [TestData.Value]
        XCTAssertFalse(cArray == other)
        other.append(TestData.Value)
        XCTAssertTrue(cArray == other)
    }
    
}
