//
//  MultimapTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/2/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class MultimapTests: XCTestCase {

    struct TestData {
        static let Dictionary = [1: 2,2: 3, 3: 4]
    }
    
    var multimap = Multimap<Int, Int>()
    
    func testEmptyMultimap() {
        XCTAssertEqual(multimap.count, 0)
        XCTAssertEqual(multimap.keyCount, 0)
        XCTAssertEqual(multimap.valuesForKey(1), [])
    }
    
    func testInitWithDictionary() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertEqual(multimap.count, TestData.Dictionary.count)
        XCTAssertEqual(multimap.keyCount, TestData.Dictionary.count)
        for (k,v) in TestData.Dictionary {
            XCTAssertTrue(multimap.containsValue(v, forKey: k))
        }
    }
    
    func testValuesForKey() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertEqual(multimap.valuesForKey(1), [2])
    }
    
    func testContainsKey() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertTrue(multimap.containsKey(1))
        XCTAssertFalse(multimap.containsKey(100))
    }
    
    func testContainsValueForKey() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertTrue(multimap.containsValue(3, forKey: 2))
        XCTAssertFalse(multimap.containsValue(2, forKey: 2))
        XCTAssertFalse(multimap.containsValue(2, forKey: 100))
    }
    
    func testSubscript() {
        multimap = Multimap(TestData.Dictionary)
        XCTAssertEqual(multimap.valuesForKey(1), [2])
        XCTAssertEqual(multimap.valuesForKey(100), [])
    }
    
    func testInsertValueForKey() {
        multimap.insertValue(10, forKey: 5)
        XCTAssertEqual(multimap.count, 1)
        XCTAssertEqual(multimap.keyCount, 1)
        XCTAssertEqual(multimap[5], [10])
    }
    
    func testInsertValuesForKey() {
        multimap.insertValues([1, 2], forKey: 5)
        XCTAssertEqual(multimap.count, 2)
        XCTAssertEqual(multimap.keyCount, 1)
        XCTAssertTrue(multimap.containsValue(1, forKey: 5))
        XCTAssertTrue(multimap.containsValue(2, forKey: 5))
        XCTAssertFalse(multimap.containsValue(3, forKey: 5))
    }
    
    func testReplaceValuesForKey() {
        multimap.insertValues([1, 2, 3], forKey: 5)
        multimap.insertValues([1, 2, 3], forKey: 10)
        multimap.replaceValues([10], forKey: 5)
        XCTAssertEqual(multimap.count, 4)
        XCTAssertEqual(multimap.keyCount, 2)
        XCTAssertEqual(multimap[5], [10])
    }
    
    func testRemoveValueForKey() {
        multimap.insertValues([1, 2, 2], forKey: 5)
        multimap.removeValue(2, forKey: 5)
        XCTAssertEqual(multimap.count, 2)
        XCTAssertEqual(multimap.keyCount, 1)
        XCTAssertTrue(multimap.containsValue(1, forKey: 5))
        XCTAssertTrue(multimap.containsValue(2, forKey: 5))
        multimap.removeValue(2, forKey: 5)
        XCTAssertFalse(multimap.containsValue(2, forKey: 5))
        XCTAssertTrue(multimap.containsValue(1, forKey: 5))
    }
    
    func testRemoveValuesForKey() {
        multimap.insertValues([1, 2, 2], forKey: 5)
        multimap.insertValues([2], forKey: 10)
        multimap.removeValuesForKey(5)
        XCTAssertEqual(multimap.count, 1)
        XCTAssertEqual(multimap.keyCount, 1)
        XCTAssertFalse(multimap.containsValue(1, forKey: 5))
        XCTAssertTrue(multimap.containsValue(2, forKey: 10))
    }
    
    func testRemoveAll() {
        multimap = Multimap(TestData.Dictionary)
        multimap.removeAll(keepCapacity: true)
        XCTAssertEqual(multimap.count, 0)
        XCTAssertEqual(multimap.keyCount, 0)
        XCTAssertEqual(multimap.valuesForKey(1), [])
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        multimap.insertValues([1, 2, 2], forKey: 5)
        multimap.insertValues([5], forKey: 10)
        var values = [1, 2, 2, 5]
        var keys = [5,5,5, 10]
        for (key, value) in multimap {
            if let index = values.indexOf(value) {
                values.removeAtIndex(index)
            }
            if let index = keys.indexOf(key) {
                keys.removeAtIndex(index)
            }
        }
        XCTAssertEqual(values.count, 0)
        XCTAssertEqual(keys.count, 0)
    }
    
    // MARK: DictionaryLiteralConvertible
    
    func testDictionaryLiteralConvertibleConformance() {
        multimap = [1:2, 2:2, 2:2]
        XCTAssertEqual(multimap.count, 3)
        XCTAssertEqual(multimap.keyCount, 2)
        XCTAssertEqual(multimap.valuesForKey(1), [2])
        XCTAssertEqual(multimap.valuesForKey(2), [2,2])
    }
    
    // MARK: Equatable
    
    func testEquatableConformance() {
        multimap = Multimap(TestData.Dictionary)
        var other = Multimap<Int, Int>()
        XCTAssertTrue(multimap != other)
        other = Multimap(multimap)
        XCTAssertTrue(multimap == other)
    }
}
