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
        static let DistinctCount = 5
    }
    
    var multiset = Multiset<Int>()
    
    func testEmptyMultiset() {
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.distinctCount, 0)
        XCTAssertEqual(multiset.remove(TestData.Value), 0)
        XCTAssertFalse(multiset.contains(TestData.Value))
    }
    
    func testInitWithArray() {
        multiset = Multiset(TestData.List)
        XCTAssertEqual(multiset.count, TestData.List.count)
        XCTAssertEqual(multiset.distinctCount, TestData.DistinctCount)
        for e in TestData.List {
            XCTAssertEqual(TestData.List.filter{$0==e}.count, multiset.count(e))
            XCTAssertTrue(multiset.contains(e))
        }
    }
    
    func testSingleInsert() {
        multiset.insert(TestData.Value)
        XCTAssertEqual(multiset.count, 1)
        XCTAssertEqual(multiset.distinctCount, 1)
        XCTAssertEqual(multiset.count(TestData.Value), 1)
    }
    
    func testConsecutiveInserts() {
        multiset.insert(TestData.Value)
        multiset.insert(TestData.Value)
        XCTAssertEqual(multiset.count, 2)
        XCTAssertEqual(multiset.distinctCount, 1)
        XCTAssertEqual(multiset.count(TestData.Value), 2)
    }
    
    func testSingleInsertoccurrences() {
        let prev = multiset.insert(TestData.Value, occurrences: 5)
        XCTAssertEqual(prev, 0)
        XCTAssertEqual(multiset.count, 5)
        XCTAssertEqual(multiset.distinctCount, 1)
        XCTAssertEqual(multiset.count(TestData.Value), 5)
    }
    
    func testConsecutiveInsertoccurrences() {
        multiset.insert(TestData.Value, occurrences: 5)
        let prev = multiset.insert(TestData.Value, occurrences: 5)
        XCTAssertEqual(prev, 5)
        XCTAssertEqual(multiset.count, 10)
        XCTAssertEqual(multiset.distinctCount, 1)
        XCTAssertEqual(multiset.count(TestData.Value), 10)
    }
    
    func testEmptyRemove() {
        XCTAssertEqual(multiset.remove(TestData.Value), 0)
    }
    
    func testRemove() {
        multiset.insert(TestData.Value, occurrences: 5)
        XCTAssertEqual(multiset.remove(TestData.Value), 5)
        XCTAssertEqual(multiset.count(TestData.Value), 4)
        XCTAssertEqual(multiset.count, 4)
        XCTAssertEqual(multiset.distinctCount, 1)
    }
    
    func testRemoveUnique() {
        multiset.insert(TestData.Value, occurrences: 1)
        XCTAssertEqual(multiset.remove(TestData.Value), 1)
        XCTAssertEqual(multiset.count(TestData.Value), 0)
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.distinctCount, 0)
    }
    
    func testRemoveoccurrences() {
        multiset.insert(TestData.Value, occurrences: 5)
        XCTAssertEqual(multiset.remove(TestData.Value, occurrences: 2), 5)
        XCTAssertEqual(multiset.count(TestData.Value), 3)
        XCTAssertEqual(multiset.count, 3)
        XCTAssertEqual(multiset.distinctCount, 1)
    }
    
    func testRemoveoccurrencesMax() {
        multiset.insert(TestData.Value, occurrences: 5)
        XCTAssertEqual(multiset.remove(TestData.Value, occurrences: 10), 5)
        XCTAssertEqual(multiset.count(TestData.Value), 0)
        XCTAssertFalse(multiset.contains(TestData.Value))
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.distinctCount, 0)
    }
    
    func testRemoveAllOf() {
        multiset.insert(TestData.Value, occurrences: 5)
        XCTAssertEqual(multiset.removeAllOf(TestData.Value), 5)
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.distinctCount, 0)
    }
    
    func testRemoveAll() {
        multiset = Multiset(TestData.List)
        multiset.removeAll(keepCapacity: true)
        XCTAssertEqual(multiset.count, 0)
        XCTAssertEqual(multiset.distinctCount, 0)
    }
    
    func testToSet() {
        multiset = Multiset(TestData.List)
        let set = Set(multiset)
        XCTAssertEqual(set.count, TestData.DistinctCount)
        for e in TestData.List {
            XCTAssertTrue(set.contains(e))
        }
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        multiset = Multiset(TestData.List)
        var list = TestData.List
        for element in multiset {
            if let index = find(list, element) {
                list.removeAtIndex(index)
            }
        }
        XCTAssertEqual(list.count, 0)
    }
    
    // MARK: ArrayLiteralConvertible
    
    func testArrayLiteralConvertibleConformance() {
        multiset = [1,2,2,3]
        XCTAssertEqual(multiset.count, 4)
        XCTAssertEqual(multiset.distinctCount, 3)
    }
    
    // MARK: Hashable and Equatable
    
    func testHashableConformance() {
        multiset = Multiset(TestData.List)
        var other = Multiset<Int>()
        XCTAssertNotEqual(multiset.hashValue, other.hashValue)
        XCTAssertTrue(multiset != other)
        other = Multiset(TestData.List.reverse())
        XCTAssertEqual(multiset.hashValue, other.hashValue)
        XCTAssertTrue(multiset == other)
    }

}