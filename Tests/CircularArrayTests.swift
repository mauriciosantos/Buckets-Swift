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
        let count = 20
        cArray = CircularArray(count: count, repeatedValue: TestData.Value)
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
        let reverseList = reverse(TestData.List)
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
    
    func testEmptyRemoveFirst() {
        XCTAssertNil(cArray.removeFirst())
        XCTAssertEqual(cArray.count, 0)
    }
    
    func testNonEmptyRemoveFirst() {
        cArray = CircularArray(elements: TestData.List)
        let first = cArray.removeFirst()
        XCTAssertTrue(first != nil && first == TestData.List.first!)
        XCTAssertEqual(cArray.count, TestData.List.count - 1)
        for i in 1..<TestData.List.count {
            XCTAssertEqual(cArray[i-1], TestData.List[i])
        }
    }
    
    func testEmptyRemoveLast() {
        XCTAssertNil(cArray.removeLast())
        XCTAssertEqual(cArray.count, 0)
    }
    
    func testNonEmptyRemoveLast() {
        cArray = CircularArray(elements: TestData.List)
        
        let last = cArray.removeLast()
        XCTAssertTrue(last != nil && last == TestData.List.last!)
        XCTAssertEqual(cArray.count, TestData.List.count - 1)
        
        XCTAssertEqual(cArray.count, TestData.List.count - 1)
        for i in 0..<cArray.count {
            XCTAssertEqual(cArray[i], TestData.List[i])
        }
    }
    
    
    func testInsertAtIndex() {
        for i in 0..<TestData.List.count {
            for j in 0...i {
                var list = [] + TestData.List[0...i]
                var array = CircularArray(elements: list)
                list.insert(TestData.Value, atIndex: j)
                array.insert(TestData.Value, atIndex: j)
                XCTAssertEqual(array.count, list.count)
                XCTAssertTrue(equal(list, array))
            }
        }
    }
    
    
    func testRemoveAtIndex() {
        for i in 0..<TestData.List.count {
            for j in 0...i {
                var list = [] + TestData.List[0...i]
                var array = CircularArray(elements: list)
                XCTAssertEqual(list.removeAtIndex(j), array.removeAtIndex(j))
                XCTAssertEqual(array.count, list.count)
                XCTAssertTrue(equal(list, array))
            }
        }
    }
    
    func testRemoveAll() {
        cArray = CircularArray(elements: TestData.List)
        cArray.removeAll(keepCapacity: true)
        XCTAssertEqual(cArray.count, 0)
        XCTAssertNil(cArray.removeFirst())
    }
    
    func testAppendAfterRemoveAll() {
        cArray = CircularArray(elements: TestData.List)
        cArray.removeAll(keepCapacity: true)
        cArray.append(TestData.Value)
        XCTAssertTrue(cArray.first != nil && cArray.first! == TestData.Value)
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        cArray = CircularArray(elements: TestData.List)
        XCTAssertTrue(equal(cArray, TestData.List))
    }
    
    // MARK: MutableCollectionType
    
    func testSubscriptGet() {
        for i in 0..<TestData.List.count {
            let list = [] + TestData.List[0...i]
            cArray = CircularArray(elements: list)
            for j in 0...i {
                XCTAssertEqual(cArray[j], list[j])
            }
            XCTAssertEqual(cArray[0], cArray.first!)
            XCTAssertEqual(cArray[i], cArray.last!)
        }
    }
    
    func testSubscriptSet() {
        let reversedList = reverse(TestData.List)
        cArray = CircularArray(count: reversedList.count, repeatedValue: 0)
        for i in 0..<reversedList.count {
            cArray[i] = reversedList[i]
            XCTAssertEqual(cArray[i], reversedList[i])
        }
    }
    
    // MARK: ArrayLiteralConvertible
    
    func testArrayLiteralConvertibleConformance() {
        cArray = [1,2,3]
        XCTAssertTrue(equal(cArray, [1,2,3]))
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