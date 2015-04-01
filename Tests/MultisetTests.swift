//
//  MultisetTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 3/31/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class MultisetTests: XCTestCase {
    
    struct TestData {
        static let Value = 50
        static let List = [4,5,3,3,1,2,2]
        static let UniqueCount = 5
    }
    
    var multiset = Multiset<Int>()
    
    func testEmptyMultiset() {
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.uniqueCount, 0)
        XCTAssertEqual(multiset.remove(TestData.Value), 0)
        XCTAssertFalse(multiset.contains(TestData.Value))
    }
    
    func testInitWithArray() {
        multiset = Multiset(elements: TestData.List)
        XCTAssertEqual(multiset.count, TestData.List.count)
        XCTAssertEqual(multiset.uniqueCount, TestData.UniqueCount)
        for e in TestData.List {
            XCTAssertEqual(TestData.List.filter{$0==e}.count, multiset.ocurrences(e))
            XCTAssertTrue(multiset.contains(e))
        }
    }
    
    func testSingleInsert() {
        multiset.insert(TestData.Value)
        XCTAssertEqual(multiset.count, 1)
        XCTAssertEqual(multiset.uniqueCount, 1)
        XCTAssertEqual(multiset.ocurrences(TestData.Value), 1)
    }
    
    func testConsecutiveInserts() {
        multiset.insert(TestData.Value)
        multiset.insert(TestData.Value)
        XCTAssertEqual(multiset.count, 2)
        XCTAssertEqual(multiset.uniqueCount, 1)
        XCTAssertEqual(multiset.ocurrences(TestData.Value), 2)
    }
    
    func testSingleInsertOcurrences() {
        let prev = multiset.insert(TestData.Value, ocurrences: 5)
        XCTAssertEqual(prev, 0)
        XCTAssertEqual(multiset.count, 5)
        XCTAssertEqual(multiset.uniqueCount, 1)
        XCTAssertEqual(multiset.ocurrences(TestData.Value), 5)
    }
    
    func testConsecutiveInsertOcurrences() {
        multiset.insert(TestData.Value, ocurrences: 5)
        let prev = multiset.insert(TestData.Value, ocurrences: 5)
        XCTAssertEqual(prev, 5)
        XCTAssertEqual(multiset.count, 10)
        XCTAssertEqual(multiset.uniqueCount, 1)
        XCTAssertEqual(multiset.ocurrences(TestData.Value), 10)
    }
    
    func testEmptyRemove() {
        XCTAssertEqual(multiset.remove(TestData.Value), 0)
    }
    
    func testRemove() {
        multiset.insert(TestData.Value, ocurrences: 5)
        XCTAssertEqual(multiset.remove(TestData.Value), 5)
        XCTAssertEqual(multiset.ocurrences(TestData.Value), 4)
        XCTAssertEqual(multiset.count, 4)
        XCTAssertEqual(multiset.uniqueCount, 1)
    }
    
    func testRemoveUnique() {
        multiset.insert(TestData.Value, ocurrences: 1)
        XCTAssertEqual(multiset.remove(TestData.Value), 1)
        XCTAssertEqual(multiset.ocurrences(TestData.Value), 0)
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.uniqueCount, 0)
    }
    
    func testRemoveOcurrences() {
        multiset.insert(TestData.Value, ocurrences: 5)
        XCTAssertEqual(multiset.remove(TestData.Value, ocurrences: 2), 5)
        XCTAssertEqual(multiset.ocurrences(TestData.Value), 3)
        XCTAssertEqual(multiset.count, 3)
        XCTAssertEqual(multiset.uniqueCount, 1)
    }
    
    func testRemoveOcurrencesMax() {
        multiset.insert(TestData.Value, ocurrences: 5)
        XCTAssertEqual(multiset.remove(TestData.Value, ocurrences: 10), 5)
        XCTAssertEqual(multiset.ocurrences(TestData.Value), 0)
        XCTAssertFalse(multiset.contains(TestData.Value))
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.uniqueCount, 0)
    }
    
    func testRemoveAllOf() {
        multiset.insert(TestData.Value, ocurrences: 5)
        XCTAssertEqual(multiset.removeAllOf(TestData.Value), 5)
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.uniqueCount, 0)
    }
    
    func testRemoveAll() {
        multiset = Multiset(elements: TestData.List)
        multiset.removeAll(keepCapacity: true)
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.uniqueCount, 0)
    }
    
    func testToSet() {
        multiset = Multiset(elements: TestData.List)
        let set = Set(multiset)
        XCTAssertEqual(set.count, TestData.UniqueCount)
        for e in TestData.List {
            XCTAssertTrue(set.contains(e))
        }
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        multiset = Multiset(elements: TestData.List)
        var list = TestData.List
        for element in multiset {
            for _ in 0..<multiset.ocurrences(element) {
                if let index = find(list, element) {
                    list.removeAtIndex(index)
                }
            }
           
        }
        XCTAssertEqual(list.count, 0)
    }
    
    // MARK: ArrayLiteralConvertible
    
    func testArrayLiteralConvertibleConformance() {
        multiset = [1,2,2,3]
        XCTAssertEqual(multiset.count, 4)
        XCTAssertEqual(multiset.uniqueCount, 3)
    }
    
    // MARK: Hashable and Equatable
    
    func testHashableConformance() {
        multiset = Multiset(elements: TestData.List)
        var other = Multiset<Int>()
        XCTAssertNotEqual(multiset.hashValue, other.hashValue)
        XCTAssertTrue(multiset != other)
        other = Multiset(elements: TestData.List.reverse())
        XCTAssertEqual(multiset.hashValue, other.hashValue)
        XCTAssertTrue(multiset == other)
    }

}