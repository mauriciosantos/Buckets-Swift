//
//  Bimap.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/2/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A Bimap is a special kind of dictionary that allows bidirectional lookup between keys and values.
/// All keys and values must be unique.
/// It allows to get, set, or delete a key-value pairs using
/// subscript notation: `bimap[value: aValue] = aKey` or `bimap[key: aKey] = aValue`
///
/// Conforms to `Sequence`, `Collection`, `ExpressibleByDictionaryLiteral`,
/// `Equatable`, `Hashable` and `CustomStringConvertible`.
public struct Bimap<Key: Hashable, Value: Hashable> {
    
    // MARK: Creating a Bimap
    
    /// Constructs an empty bimap.
    public init() {}
    
    /// Constructs a bimap with at least the given number of
    /// elements worth of storage. The actual capacity will be the
    /// smallest power of 2 that's >= `minimumCapacity`.
    public init(minimumCapacity: Int) {
        keysToValues = [Key: Value](minimumCapacity: minimumCapacity)
        valuesToKeys = [Value: Key](minimumCapacity: minimumCapacity)
    }
    
    /// Constructs a bimap from a dictionary.
    public init(_ elements: Dictionary<Key, Value>) {
        for (k, value) in elements {
            self[key: k] = value
        }
    }
    
    /// Constructs a bimap from a sequence of key-value pairs.
    public init<S:Sequence>(_ elements: S) where S.Iterator.Element == (Key, Value) {
        for (k, value) in elements {
            self[key: k] = value
        }
    }
    
    // MARK:  Querying a Bimap
    
    /// Number of key-value pairs stored in the bimap.
    public var count: Int {
        return keysToValues.count
    }
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return keysToValues.isEmpty
    }
    
    /// A collection containing all the bimap's keys.
    public var keys: AnyCollection<Key> {
        return AnyCollection(keysToValues.keys)
    }
    
    /// A collection containing all the bimap's values.
    public var values: AnyCollection<Value> {
        return AnyCollection(valuesToKeys.keys)
    }

    // MARK: Accessing and Changing Bimap Elements
    
    // Gets, sets, or deletes a key-value pair in the bimap using square bracket subscripting.
    public subscript(value value: Value) -> Key? {
        get {
            return valuesToKeys[value]
        }
        set(newKey) {
            let oldKey = valuesToKeys.removeValue(forKey: value)
            if let oldKey = oldKey {
                keysToValues.removeValue(forKey: oldKey)
            }
            valuesToKeys[value] = newKey
            if let newKey = newKey {
                keysToValues[newKey] = value
            }
        }
    }
    
    // Gets, sets, or deletes a key-value pair in the bimap using square bracket subscripting.
    public subscript(key key: Key) -> Value? {
        get {
            return keysToValues[key]
        }
        set {
            let oldValue = keysToValues.removeValue(forKey: key)
            if let oldValue = oldValue {
                valuesToKeys.removeValue(forKey: oldValue)
            }
            keysToValues[key] = newValue
            if let newValue = newValue {
                valuesToKeys[newValue] = key
            }
        }
    }
    
    /// Inserts or updates a value for a given key and returns the previous value 
    /// for that key if one existed, or `nil` if a previous value did not exist.
    /// Subscript access is preferred.
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        let previous = self[key: key]
        self[key: key] = value
        return previous
    }
    
    /// Removes the key-value pair for the given key and returns its value,
    /// or `nil` if a value for that key did not previously exist.
    /// Subscript access is preferred.
    @discardableResult
    public mutating func removeValueForKey(_ key: Key) -> Value? {
        let previous = self[key: key]
        self[key: key] = nil
        return previous
    }
    
    /// Removes the key-value pair for the given value and returns its key,
    /// or `nil` if a key for that value did not previously exist.
    /// Subscript access is preferred.
    @discardableResult
    public mutating func removeKeyForValue(_ value: Value) -> Key? {
        let previous = self[value: value]
        self[value: value] = nil
        return previous
    }
    
    /// Removes all the elements from the bimap, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true) {
        valuesToKeys.removeAll(keepingCapacity: keep)
        keysToValues.removeAll(keepingCapacity: keep)
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Internal structure mapping keys to values.
    fileprivate var keysToValues = [Key: Value]()
    
    /// Internal structure values keys to keys.
    fileprivate var valuesToKeys = [Value: Key]()
}

extension Bimap: Sequence {
    
    // MARK: Sequence Protocol Conformance
    
    /// Provides for-in loop functionality.
    ///
    /// - returns: A generator over the elements.
    public func makeIterator() -> DictionaryIterator<Key, Value> {
        return keysToValues.makeIterator()
    }
}

extension Bimap: Collection {
    
    
    // MARK: Collection Protocol Conformance
    
    /// The position of the first element in a non-empty bimap.
    ///
    /// Identical to `endIndex` in an empty bimap
    ///
    /// Complexity: amortized O(1)
    public var startIndex: DictionaryIndex<Key, Value> {
        return keysToValues.startIndex
    }
    
    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    ///
    /// Complexity: amortized O(1)
    public var endIndex: DictionaryIndex<Key, Value> {
        return keysToValues.endIndex
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: DictionaryIndex<Key, Value>) -> DictionaryIndex<Key, Value> {
        return keysToValues.index(after: i)
    }

    
    public subscript(position: DictionaryIndex<Key, Value>) -> (key: Key, value: Value) {
        return keysToValues[position]
    }
}

extension Bimap: ExpressibleByDictionaryLiteral {
    
    // MARK: ExpressibleByDictionaryLiteral Protocol Conformance
    
    /// Constructs a bimap using a dictionary literal.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements)
    }
}

extension Bimap: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the bimap.
    public var description: String {
        return keysToValues.description
    }
}

extension Bimap: Hashable {
    
    // MARK: Hashable Protocol Conformance
    
    /// The hash value.
    /// `x == y` implies `x.hashValue == y.hashValue`
    public var hashValue: Int {
        var result = 78
        for (key, value) in self {
            result = (31 ^ result) ^ key.hashValue
            result = (31 ^ result) ^ value.hashValue
        }
        return result
    }
}

// MARK: Bimap Equatable Conformance

/// Returns `true` if and only if the bimaps contain the same key-value pairs.
public func ==<Key, Value>(lhs: Bimap<Key, Value>, rhs: Bimap<Key, Value>) -> Bool {
    if lhs.count != rhs.count{
        return false
    }
    for (k,v) in lhs {
        if rhs[key: k] != v {
            return false
        }
    }
    return true
}
