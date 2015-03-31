//
//  Multiset.swift
//  Buckets
//
//  Created by Mauricio Santos on 3/28/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A Multiset (sometimes called a bag) is a special kind of set in which 
/// members are allowed to appear more than once.
///
/// Comforms to `SequenceType`, `ArrayLiteralConvertible`,
/// `Equatable`, `Hashable`, `Printable` and `DebugPrintable`.
public struct Multiset<T: Hashable> {

    // MARK: Properties
    
    /// Number of elements stored in the multiset, including multiple copies.
    public private(set) var count = 0
    
    /// `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// Number of unique elements stored in the multiset.
    public var uniqueCount: Int {
        return members.count
    }
    
    private var members = [T:Int]()
    
    // MARK: Creating a Multiset
    
    /// Constructs an empty Multiset of type `T`.
    public init() {}
    
    /// Constructs a Multiset from a sequence, such as an array.
    public init<S: SequenceType where S.Generator.Element == T>(elements: S){
        for e in elements {
            insert(e)
        }
    }
    
    // MARK: Querying a Multiset
    
    /// Returns `true` if the multiset contains the specified element.
    public func contains(element: T) -> Bool {
        return members[element] == nil ? false : true
    }
    
    /// Returns the number of occurences of an element.
    public func countOf(element: T) -> Int {
        return members[element] ?? 0
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts a single ocurrence of an element into the multiset.
    ///
    /// :returns: The number of ocurrences of the element before the operation.
    public mutating func insert(element: T) -> Int {
        return insert(element, ocurrences: 1)
    }
    
    /// Inserts a number of occurrences of an element into the multiset.
    ///
    /// :returns: The number of ocurrences of the element before the operation.
    public mutating func insert(element: T, ocurrences: Int) -> Int {
        if count < 1 {
            fatalError("Can't insert < 1 ocurrences")
        }
        let previousNumber = members[element] ?? 0
        
        members[element] = previousNumber + ocurrences
        count += ocurrences
        return previousNumber
    }
    
    /// Removes a single occurrence of an element from the multiset, if present.
    ///
    /// :returns: The number of ocurrences of the element before the operation.
    public mutating func remove(element: T) -> Int {
        return remove(element, ocurrences: 1)
    }
    
    /// Removes a number of occurrences of an element from the multiset.
    /// If the multiset contains fewer than this number of occurrences to begin with,
    /// all occurrences will be removed.
    ///
    /// :returns: The number of ocurrences of the element before the operation.
    public mutating func remove(element: T, ocurrences: Int) -> Int {
        if count < 1 {
            fatalError("Can't remove < 1 ocurrences")
        }
        if let currentOcurrences = members[element] {
            let nRemoved = min(currentOcurrences, ocurrences)
            count -= nRemoved
            let newOcurrencies = currentOcurrences - nRemoved
            if newOcurrencies == 0 {
                members.removeValueForKey(element)
            } else {
                members[element] = newOcurrencies
            }
            return nRemoved
        } else {
            return 0
        }
    }

    /// Removes all occurrences of an element from the multiset, if present.
    ///
    /// :returns: The number of ocurrences of the element before the operation.
    public mutating func removeAllOf(element: T) -> Int {
        let ocurrences = countOf(element)
        if ocurrences >= 1 {
            return remove(element, ocurrences: countOf(element))
        }
        return 0
    }
    
    /// Removes all the elements from the multiset, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true) {
        members.removeAll(keepCapacity: keep)
        count = 0
    }
    
    // MARK: Transforming a Multiset
    
    /// Returns a set containing all the elements in the multiset.
    public func toSet() -> Set<T> {
        return Set(members.keys)
    }
}

// MARK: - SequenceType

extension Multiset: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality. Generates a single ocurrence per element.
    ///
    /// :returns: A generator over the elements.
    public func generate() -> GeneratorOf<T> {
        var keyValueGenerator = members.generate()
        return GeneratorOf<T> {
            return keyValueGenerator.next()?.0
        }
    }
}

// MARK: - ArrayLiteralConvertible

extension Multiset: ArrayLiteralConvertible {
    
    // MARK: ArrayLiteralConvertible Protocol Conformance
    
    /// Constructs a multiset using an array literal.
    /// Unlike a set, multiple copies of an element are inserted.
    public init(arrayLiteral elements: T...) {
        self.init(elements: elements)
    }
}

// MARK: - Hashable

extension Multiset: Hashable {
    
    // MARK: Hashable Protocol Conformance
    
    /// The hash value.
    /// `x == y` implies `x.hashValue == y.hashValue`
    public var hashValue: Int {
        var result = 3
        for element in self {
            result = 37 &* result &+ element.hashValue
        }
        return result
    }
}

// MARK: Multiset Operators

/// Returns `true` if and only if the multisets contain the same number of ocurrences per element.
public func ==<T>(lhs: Multiset<T>, rhs: Multiset<T>) -> Bool {
    if lhs.count != rhs.count || lhs.uniqueCount != rhs.uniqueCount {
        return false
    }
    for element in lhs {
        if lhs.countOf(element) != rhs.countOf(element) {
            return false
        }
    }
    return true
}