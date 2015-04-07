//
//  TrieTests.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/6/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import XCTest
import Buckets

class TrieTests: XCTestCase {
    
    struct TestData {
        static let Elements = ["Hello", "Hel", "Apple", "Y", "Yes", "NO", ""]
    }
    
    var trie = Trie<String>()

    func testEmptyTrie() {
        XCTAssertEqual(trie.count, 0)
        XCTAssertEqual(trie.elements, [])
    }
    
    func testInitWithArray() {
        trie = Trie(TestData.Elements)
        XCTAssertEqual(trie.count, TestData.Elements.count)
        for element in TestData.Elements {
            XCTAssertTrue(trie.contains(element))
        }
        XCTAssertEqual(Set(trie.elements), Set(TestData.Elements))
    }
    
    func testEmptyContains() {
        XCTAssertFalse(trie.contains(""))
    }
    
    func testNonEmptyContains() {
        trie = Trie(TestData.Elements)
        for element in TestData.Elements {
            XCTAssertTrue(trie.contains(element))
        }
         XCTAssertFalse(trie.contains("H"))
    }
    
    func testContiansEmptyPrefix() {
        XCTAssertTrue(trie.containsPrefix(""))
        trie = Trie(TestData.Elements)
        XCTAssertTrue(trie.containsPrefix(""))
    }
    
    func testContiansValidPrefix() {
        trie = Trie(TestData.Elements)
        XCTAssertTrue(trie.containsPrefix("Hell"))
        XCTAssertTrue(trie.containsPrefix("H"))
        XCTAssertTrue(trie.containsPrefix("Y"))
        XCTAssertTrue(trie.containsPrefix("NO"))
    }
    
    func testContiansInvalidPrefix() {
        trie = Trie(TestData.Elements)
        XCTAssertFalse(trie.containsPrefix("Yello"))
        XCTAssertFalse(trie.containsPrefix("Hello World"))
        XCTAssertFalse(trie.containsPrefix("Yeah"))
        XCTAssertFalse(trie.containsPrefix("NOse"))
    }
    
    func testElementsMatchingPrefix() {
        trie = Trie(TestData.Elements)
        XCTAssertEqual(trie.elementsMatchingPrefix("Hello World"), [])
        XCTAssertEqual(Set(trie.elementsMatchingPrefix("")), Set(TestData.Elements))
        XCTAssertEqual(Set(trie.elementsMatchingPrefix("Y")), Set(["Y", "Yes"]))
        XCTAssertEqual(Set(trie.elementsMatchingPrefix("Hel")), Set(["Hel", "Hello"]))
        XCTAssertEqual(Set(trie.elementsMatchingPrefix("NO")), Set(["NO"]))
    }
    
    func testLongestPrefixMatching() {
        trie = Trie(TestData.Elements)
        XCTAssertEqual(trie.longestPrefixMatching(""), "")
        XCTAssertEqual(trie.longestPrefixMatching("abc"), "")
        XCTAssertEqual(trie.longestPrefixMatching("Hello World"), "Hello")
        XCTAssertEqual(trie.longestPrefixMatching("Hel"), "Hel")
        XCTAssertEqual(trie.longestPrefixMatching("Y"), "Y")
        XCTAssertEqual(trie.longestPrefixMatching("Apple"), "Apple")
    }
    
    func testInsert() {
        trie.insert("abc")
        XCTAssertEqual(trie.elements, ["abc"])
        XCTAssertTrue(trie.contains("abc"))
    }
    
    func testRemoveFromEmptyTrie() {
        XCTAssertNil(trie.remove(""))
        XCTAssertEqual(trie.count, 0)
    }
    
    func testRemove() {
        trie = Trie(TestData.Elements)
        XCTAssertNotNil(trie.remove(""))
        XCTAssertFalse(trie.contains(""))
        XCTAssertEqual(Set(trie.elements), Set(["Hello", "Hel", "Apple", "Y", "Yes", "NO"]))
        XCTAssertNil(trie.remove("H"))
        XCTAssertEqual(Set(trie.elements), Set(["Hello", "Hel", "Apple", "Y", "Yes", "NO"]))
        XCTAssertNotNil(trie.remove("Y"))
        XCTAssertEqual(Set(trie.elements), Set(["Hello", "Hel", "Apple", "Yes", "NO"]))
        XCTAssertNotNil(trie.remove("Hello"))
        XCTAssertEqual(Set(trie.elements), Set(["Hel", "Apple", "Yes", "NO"]))
        XCTAssertEqual(trie.count, TestData.Elements.count - 3)
    }
    
    func testRemoveAll() {
        trie = Trie(TestData.Elements)
        trie.removeAll()
        XCTAssertEqual(trie.count, 0)
        XCTAssertEqual(trie.elements, [])
    }
    
    // MARK: Hashable and Equatable
    
    func testHashableConformance() {
        trie = Trie(TestData.Elements)
        var other = Trie<String>()
        XCTAssertNotEqual(trie.hashValue, other.hashValue)
        XCTAssertTrue(trie != other)
        other = Trie(TestData.Elements.reverse())
        XCTAssertEqual(trie.hashValue, trie.hashValue)
        XCTAssertTrue(trie == other)
    }

}
