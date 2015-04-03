//
//  Bimap.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/2/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A Bimap is a special kind of dictionary that allows bidirectional lookup between key and values.
/// It allows to get, set, or delete a key-value pair using
/// subscript notation: `bimap[value: theValue]` or `bimap[key: thekey]`
///
/// Comforms to `SequenceType`, `CollectionType`, `DictionaryLiteralConvertible`,
/// `Equatable`, `Hashable`, `Printable` and `DebugPrintable`.
public struct Bimap<Key: Hashable, Value: Hashable> {
    
    // MARK: Properties
    
    /// Number of key-value pairs stored in the multimap.
    public var count: Int {
        return keysToValues.count
    }
    
    /// `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return keysToValues.isEmpty
    }
    
    /// An unordered iterable collection of all of a bimap's keys (read-only).
    public var keys: LazyForwardCollection<MapCollectionView<[Key : Value], Key>> {
        return keysToValues.keys
    }
    
    /// An unordered iterable collection of all of a bimap's values (read-only).
    public var values: LazyForwardCollection<MapCollectionView<[Value : Key], Value>> {
        return valuesToKeys.keys
    }

    private var keysToValues = [Key: Value]()
    private var valuesToKeys = [Value: Key]()
    
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
    
    /// Constructs a bimap from a sequence of key-value pairs, such as a dictionary.
    public init<S:SequenceType where S.Generator.Element == (Key, Value)>(_ elements: S) {
        for (k, value) in elements {
            self[key: k] = value
        }
    }
    
    // MARK: Accessing and Changing Bimap Elements
    
    /// Gets, sets, or deletes a key-value pair in a bimap using square bracket subscripting.
    public subscript(#key: Key) -> Value? {
        get {
            return keysToValues[key]
        }
        set {
            if newValue == nil {
                if let oldValue = keysToValues[key] {
                    valuesToKeys.removeValueForKey(oldValue)
                }
            }
            keysToValues[key] = newValue
            if let newValue = newValue {
                valuesToKeys[newValue] = key
            }
        }
    }
    
    /// Gets, sets, or deletes a key-value pair in a bimap using square bracket subscripting.
    public subscript(#value: Value) -> Key? {
        get {
            return valuesToKeys[value]
        }
        set(newKey) {
            if newKey == nil {
                if let oldKey = valuesToKeys[value] {
                    keysToValues.removeValueForKey(oldKey)
                }
            }
            valuesToKeys[value] = newKey
            if let newKey = newKey {
                keysToValues[newKey] = value
            }
        }
    }
    
    
    /// Inserts or updates a value for a given key and returns the previous value 
    /// for that key if one existed, or `nil` if a previous value did not exist.
    public mutating func updateValue(value: Value, forKey key: Key) -> Value? {
        let previous = self[key: key]
        self[key: key] = value
        return previous
    }
    
    /// Removes the key-value pair for the specified key and returns its value, 
    /// or `nil` if a value for that key did not previously exist
    public mutating func removeValueForKey(key: Key) -> Value? {
        let previous = self[key: key]
        self[key: key] = nil
        return previous
    }
    
    /// Removes the key-value pair for the specified value and returns its key,
    /// or `nil` if a key for that value did not previously exist
    public mutating func removeKeyForValue(value: Value) -> Key? {
        let previous = self[value: value]
        self[value: value] = nil
        return previous
    }
    
    /// Removes all the elements from the Bimap, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true) {
        keysToValues.removeAll(keepCapacity: keep)
    }
}

// MARK: - SequenceType

extension Bimap: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality.
    ///
    /// :returns: A generator over the elements.
    public func generate() -> DictionaryGenerator<Key, Value> {
        return keysToValues.generate()
    }
}

// MARK: - CollectionType

extension Bimap: CollectionType {
    
    // MARK: SequenceType Protocol Conformance
    
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
    
    public subscript (position: DictionaryIndex<Key, Value>) -> (Key, Value) {
        return keysToValues[position]
    }
}

// MARK: - DictionaryLiteralConvertible

extension Bimap: DictionaryLiteralConvertible {
    
    // MARK: DictionaryLiteralConvertible Protocol Conformance
    
    /// Constructs a bimap using a dictionary literal.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements)
    }
}

// MARK: - Printable

extension Bimap: Printable, DebugPrintable {
    
    // MARK: Printable Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the bimap.
    public var description: String {
        return keysToValues.description
    }
    
    // MARK: DebugPrintable Protocol Conformance
    
    /// A string containing a suitable textual representation
    /// of the bimap when debugging.
    public var debugDescription: String {
        return keysToValues.debugDescription
    }
}

// MARK: - Hashable

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

// MARK: Bimap Operators

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