//
//  BloomFilterTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/11/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class BloomFilterTests: XCTestCase {

    struct TestData {
        static let FPP: Double = 0.09
        static let List = [Int](1...10)
    }
    
    var bloomFilter = BloomFilter<Int>(expectedCount: 1000, FPP: TestData.FPP)
    
    func testEmptyBloomFilter() {
        XCTAssertEqual(bloomFilter.FPP, TestData.FPP)
        XCTAssertEqual(bloomFilter.FPP, TestData.FPP)
        XCTAssertTrue(bloomFilter.isEmpty)
        XCTAssertFalse(bloomFilter.contains(1))
    }
    
    func testInsert() {
        for i in TestData.List {
            bloomFilter.insert(i)
        }
        for i in TestData.List {
            XCTAssertTrue(bloomFilter.contains(i))
        }
        XCTAssertFalse(bloomFilter.contains(-1))
    }
    
    func testRoughCount() {
        for i in TestData.List {
            bloomFilter.insert(i)
        }
        XCTAssertTrue(bloomFilter.roughCount >= 7)
        XCTAssertTrue(bloomFilter.roughCount <= 10)
    }
    
    func testRemoveAll() {
        for i in TestData.List {
            bloomFilter.insert(i)
        }
        bloomFilter.removeAll()
        XCTAssertTrue(bloomFilter.isEmpty)
        XCTAssertFalse(bloomFilter.contains(1))
    }
}
