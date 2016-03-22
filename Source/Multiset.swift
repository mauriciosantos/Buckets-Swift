//
//  Multiset.swift
//  Buckets
//
//  Created by Mauricio Santos on 3/28/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A Multiset (sometimes called a bag) is a special kind of set in which
/// members are allowed to appear more than once. It's possible to convert a multiset
/// to a set: `let set = Set(multiset)`
///
/// Conforms to `SequenceType`, `ArrayLiteralConvertible`,
/// `Equatable`, `Hashable`, `Printable` and `DebugPrintable`.
public struct Multiset<T: Hashable> {
    
    // MARK: Creating a Multiset
    
    /// Constructs an empty multiset.
    public init() {}
    
    /// Constructs a multiset from a sequence, such as an array.
    public init<S: SequenceType where S.Generator.Element == T>(_ elements: S){
        for e in elements {
            insert(e)
        }
    }
    
    // MARK: Querying a Multiset
    
    /// Number of elements stored in the multiset, including multiple copies.
    public private(set) var count = 0
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// Number of distinct elements stored in the multiset.
    public var distinctCount: Int {
        return members.count
    }
    
    /// A sequence containing the multiset's distinct elements.
    public var distinctElements: LazySequence<LazyMapCollection<[T : Int], T>> {
        return LazySequence(members.keys)
    }
    
    /// Returns `true` if the multiset contains the given element.
    public func contains(element: T) -> Bool {
        return members[element] != nil
    }
    
    /// Returns the number of occurrences  of an element in the multiset.
    public func count(element: T) -> Int {
        return members[element] ?? 0
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts a single occurrence of an element into the multiset.
    ///
    /// - returns: The number of occurrences of the element before the operation.
    public mutating func insert(element: T) -> Int {
        return insert(element, occurrences: 1)
    }
    
    /// Inserts a number of occurrences of an element into the multiset.
    ///
    /// - returns: The number of occurrences of the element before the operation.
    public mutating func insert(element: T, occurrences: Int) -> Int {
        if occurrences < 1 {
            fatalError("Can't insert < 1 occurrences")
        }
        let previousNumber = members[element] ?? 0
        
        members[element] = previousNumber + occurrences
        count += occurrences
        return previousNumber
    }
    
    /// Removes a single occurrence of an element from the multiset, if present.
    ///
    /// - returns: The number of occurrences of the element before the operation.
    public mutating func remove(element: T) -> Int {
        return remove(element, occurrences: 1)
    }
    
    /// Removes a number of occurrences of an element from the multiset.
    /// If the multiset contains fewer than this number of occurrences to begin with,
    /// all occurrences will be removed.
    ///
    /// - returns: The number of occurrences of the element before the operation.
    public mutating func remove(element: T, occurrences: Int) -> Int {
        if occurrences < 1 {
            fatalError("Can't remove < 1 occurrences")
        }
        if let currentOccurrences = members[element] {
            let nRemoved = min(currentOccurrences, occurrences)
            count -= nRemoved
            let newOcurrencies = currentOccurrences - nRemoved
            if newOcurrencies == 0 {
                members.removeValueForKey(element)
            } else {
                members[element] = newOcurrencies
            }
            return currentOccurrences
        } else {
            return 0
        }
    }

    /// Removes all occurrences of an element from the multiset, if present.
    ///
    /// - returns: The number of occurrences of the element before the operation.
    public mutating func removeAllOf(element: T) -> Int {
        let ocurrences = count(element)
        if ocurrences >= 1 {
            return remove(element, occurrences: ocurrences)
        }
        return 0
    }
    
    /// Removes all the elements from the multiset, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true) {
        members.removeAll(keepCapacity: keep)
        count = 0
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Internal dictionary holding the elements.
    private var members = [T: Int]()
}

// MARK: -

extension Multiset: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality. Generates multiple occurrences per element.
    ///
    /// - returns: A generator over the elements.
    public func generate() -> AnyGenerator<T> {
        var keyValueGenerator = members.generate()
        var elementCount = 0
        var element : T? = nil
        return AnyGenerator {
            if elementCount > 0 {
                elementCount -= 1
                return element
            }
            let nextTuple = keyValueGenerator.next()
            element = nextTuple?.0
            elementCount = nextTuple?.1 ?? 1
            elementCount -= 1
            return element
        }
    }
}

extension Multiset: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the multiset.
    public var description: String {
        return "[" + map{"\($0)"}.joinWithSeparator(", ") + "]"
    }
}

extension Multiset: ArrayLiteralConvertible {
    
    // MARK: ArrayLiteralConvertible Protocol Conformance
    
    /// Constructs a multiset using an array literal.
    /// Unlike a set, multiple copies of an element are inserted.
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

extension Multiset: Hashable {
    
    // MARK: Hashable Protocol Conformance
    
    /// The hash value.
    /// `x == y` implies `x.hashValue == y.hashValue`
    public var hashValue: Int {
        var result = 3
        result = (31 ^ result) ^ distinctCount
        result = (31 ^ result) ^ count
        for element in self {
            result = (31 ^ result) ^ element.hashValue
        }
        return result
    }
}

// MARK: Multiset Equatable Conformance

/// Returns `true` if and only if the multisets contain the same number of occurrences per element.
public func ==<T>(lhs: Multiset<T>, rhs: Multiset<T>) -> Bool {
    if lhs.count != rhs.count || lhs.distinctCount != rhs.distinctCount {
        return false
    }
    for element in lhs {
        if lhs.count(element) != rhs.count(element) {
            return false
        }
    }
    return true
}