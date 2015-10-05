//
//  BimapTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/3/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class BimapTests: XCTestCase {
    
    struct TestData {
        static let Key = 10
        static let Value = 50
        static let Dictionary = [1: 2,2: 3, 3: 4]
    }
    
    var bimap = Bimap<Int, Int>()
    
    func testEmptyBimap() {
        XCTAssertEqual(bimap.count, 0)
        XCTAssertNil(bimap[key: TestData.Key])
        XCTAssertNil(bimap[value: TestData.Value])
    }
    
    func testInitWithDictionary() {
        bimap = Bimap(TestData.Dictionary)
        XCTAssertEqual(bimap.count, TestData.Dictionary.count)
        for (k,v) in TestData.Dictionary {
            XCTAssertNotNil(bimap[key: k])
            XCTAssertNotNil(bimap[value: v])
            XCTAssertEqual(bimap[key: k]!, v)
            XCTAssertEqual(bimap[value: v]!, k)
        }
    }
    
    func testSubscriptInsertByKey() {
        bimap[key: TestData.Key] = TestData.Value
        XCTAssertEqual(bimap.count, 1)
        XCTAssertNotNil(bimap[key: TestData.Key])
        XCTAssertNotNil(bimap[value: TestData.Value])
        XCTAssertEqual(bimap[key: TestData.Key]!, TestData.Value)
        XCTAssertEqual(bimap[value: TestData.Value]!, TestData.Key)
    }
    
    func testSubscriptInsertByValue() {
        bimap[value: TestData.Value] = TestData.Key
        XCTAssertEqual(bimap.count, 1)
        XCTAssertNotNil(bimap[key: TestData.Key])
        XCTAssertNotNil(bimap[value: TestData.Value])
        XCTAssertEqual(bimap[key: TestData.Key]!, TestData.Value)
        XCTAssertEqual(bimap[value: TestData.Value]!, TestData.Key)
    }
    
    func testSubscriptReplaceByKey() {
        bimap = Bimap(TestData.Dictionary)
        bimap[key: 1] = 200
        XCTAssertEqual(bimap.count, TestData.Dictionary.count)
        XCTAssertNotNil(bimap[key: 1])
        XCTAssertNotNil(bimap[value: 200])
        XCTAssertNil(bimap[value: 2])
        XCTAssertEqual(bimap[key: 1]!, 200)
        XCTAssertEqual(bimap[value: 200]!, 1)
    }
    
    func testSubscriptReplaceByValue() {
        bimap = Bimap(TestData.Dictionary)
        bimap[value: 2] = 200
        XCTAssertEqual(bimap.count, TestData.Dictionary.count)
        XCTAssertNotNil(bimap[value: 2])
        XCTAssertNotNil(bimap[key: 200])
        XCTAssertNil(bimap[key: 1])
        XCTAssertEqual(bimap[value: 2]!, 200)
        XCTAssertEqual(bimap[key: 200]!, 2)
    }
    
    func testSubscriptRemoveByKey() {
        bimap = Bimap(TestData.Dictionary)
        bimap[key: 1] = nil
        XCTAssertEqual(bimap.count, TestData.Dictionary.count - 1)
        XCTAssertNil(bimap[key: 1])
        XCTAssertNil(bimap[value: 2])
    }
    
    func testSubscriptRemoveByValue() {
        bimap = Bimap(TestData.Dictionary)
        bimap[value: 2] = nil
        XCTAssertEqual(bimap.count, TestData.Dictionary.count - 1)
        XCTAssertNil(bimap[key: 1])
        XCTAssertNil(bimap[value: 2])
    }
    
    func testUpdateValueForNonExistingKey() {
        bimap = Bimap(TestData.Dictionary)
        let previous = bimap.updateValue(50, forKey: 40)
        XCTAssertEqual(bimap.count, TestData.Dictionary.count + 1)
        XCTAssertNil(previous)
        XCTAssertNotNil(bimap[value: 50])
        XCTAssertNotNil(bimap[key: 40])
        XCTAssertEqual(bimap[value: 50]!, 40)
        XCTAssertEqual(bimap[key: 40]!, 50)
    }
    
    func testUpdateValueForExistingKey() {
        bimap = Bimap(TestData.Dictionary)
        let previous = bimap.updateValue(50, forKey: 1)
        XCTAssertEqual(bimap.count, TestData.Dictionary.count)
        XCTAssertNotNil(previous)
        XCTAssertEqual(previous!, 2)
        XCTAssertNotNil(bimap[value: 50])
        XCTAssertNotNil(bimap[key: 1])
        XCTAssertEqual(bimap[value: 50]!, 1)
        XCTAssertEqual(bimap[key: 1]!, 50)
    }
    
    func testUpdateKeyForNonExistingValue() {
        bimap = Bimap(TestData.Dictionary)
        let previous = bimap.updateValue(50, forKey: 40)
        XCTAssertEqual(bimap.count, TestData.Dictionary.count + 1)
        XCTAssertNil(previous)
        XCTAssertNotNil(bimap[value: 50])
        XCTAssertNotNil(bimap[key: 40])
        XCTAssertEqual(bimap[value: 50]!, 40)
        XCTAssertEqual(bimap[key: 40]!, 50)
    }
    
    func testRemoveValueForKey() {
        bimap = Bimap(TestData.Dictionary)
        let previous = bimap.removeValueForKey(1)
        XCTAssertEqual(bimap.count, TestData.Dictionary.count - 1)
        XCTAssertNotNil(previous)
        XCTAssertEqual(previous!, 2)
        XCTAssertNil(bimap[key: 1])
        XCTAssertNil(bimap[value: 2])
    }
    
    func testRemoveKeyForValue() {
        bimap = Bimap(TestData.Dictionary)
        let previous = bimap.removeKeyForValue(2)
        XCTAssertEqual(bimap.count, TestData.Dictionary.count - 1)
        XCTAssertNotNil(previous)
        XCTAssertEqual(previous!, 1)
        XCTAssertNil(bimap[key: 1])
        XCTAssertNil(bimap[value: 2])
    }
    
    func testRemoveAll() {
        bimap = Bimap(TestData.Dictionary)
        bimap.removeAll(keepCapacity: true)
        XCTAssertEqual(bimap.count, 0)
        XCTAssertNil(bimap[key: 1])
        XCTAssertNil(bimap[value: 2])
    }
    
    // MARK: SequenceType
    
    func testSequenceTypeConformance() {
        bimap = Bimap(TestData.Dictionary)
        var dictionary = TestData.Dictionary
        for (key, _) in bimap {
            dictionary.removeValueForKey(key)
        }
        XCTAssertEqual(dictionary.count, 0)
    }
    
    // MARK: DictionaryLiteralConvertible
    
    func testDictionaryLiteralConvertibleConformance() {
        bimap = [1:2, 2:3]
        XCTAssertEqual(bimap.count, 2)
        XCTAssertNotNil(bimap[key:1])
        XCTAssertNotNil(bimap[key:2])
        XCTAssertNotNil(bimap[value:2])
        XCTAssertNotNil(bimap[value:3])
        XCTAssertEqual(bimap[key: 1]!, 2)
        XCTAssertEqual(bimap[key: 2]!, 3)
        XCTAssertEqual(bimap[value: 2]!, 1)
        XCTAssertEqual(bimap[value: 3]!, 2)
    }
    
    // MARK: Hashable
    
    func testHashableConformance() {
        bimap = Bimap(TestData.Dictionary)
        var other = Bimap<Int, Int>()
        XCTAssertNotEqual(bimap.hashValue, other.hashValue)
        other = Bimap(TestData.Dictionary)
        XCTAssertEqual(bimap.hashValue, other.hashValue)
    }
    
    // MARK: Equatable
    
    func testEquatableConformance() {
        bimap = Bimap(TestData.Dictionary)
        var other = Bimap<Int, Int>()
        XCTAssertTrue(bimap != other)
        other = Bimap(bimap)
        XCTAssertTrue(bimap == other)
    }
}
