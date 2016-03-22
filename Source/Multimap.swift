//
//  Multimap.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/1/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A Multimap is a special kind of dictionary in which each key may be 
/// associated with multiple values. This implementation allows duplicate key-value pairs.
///
/// Comforms to `SequenceType`, `DictionaryLiteralConvertible`,
/// `Equatable`, `Hashable`, `Printable` and `DebugPrintable`.
public struct Multimap<Key: Hashable, Value: Equatable> {
    
    // MARK: Creating a Multimap
    
    /// Constructs an empty multimap.
    public init() {}
    
    /// Constructs a multimap from a sequence of key-value pairs, such as a dictionary or another multimap.
    public init<S:SequenceType where S.Generator.Element == (Key, Value)>(_ elements: S) {
        for (k,value) in elements {
            insertValue(value, forKey: k)
        }
    }
    
    // MARK: Querying a Multimap
    
    /// Number of key-value pairs stored in the multimap.
    public private(set) var count = 0
    
    /// Number of distinct keys stored in the multimap.
    public var keyCount: Int {
        return dictionary.count
    }
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// A sequence containing the multimap's unique keys.
    public var keys: LazySequence<LazyMapCollection<[Key : [Value]], Key>> {
        return LazySequence(dictionary.keys)
    }
    
    /// A sequence containing the multimap's values.
    public var values: LazySequence<AnyGenerator<Value>> {
        let selfGenerator = generate()
        let valueGenerator = AnyGenerator { selfGenerator.next()?.1 }
        return LazySequence(valueGenerator)
    }
    
    /// Returns an array containing the values associated with the given key.
    /// An empty array is returned if the key does not exist in the multimap.
    /// Subscript access is preferred.
    public func valuesForKey(key: Key) -> [Value] {
        if let values = dictionary[key] {
            return values
        }
        return []
    }
    
    /// Returns an array containing the values associated with the specified key.
    /// An empty array is returned if the key does not exist in the multimap.
    /// Equivalent to `valuesForKey`.
    public subscript(key: Key) -> [Value] {
        return valuesForKey(key)
    }
    
    /// Returns `true` if the multimap contains at least one key-value pair with the given key.
    public mutating func containsKey(key: Key) -> Bool {
        return dictionary[key] != nil
    }
    
    /// Returns `true` if the multimap contains at least one key-value pair with the given key and value.
    public func containsValue(value: Value, forKey key: Key) -> Bool {
        if let values = dictionary[key] {
            return values.contains(value)
        }
        return false
    }
    
    // MARK: Accessing and Changing Multimap Elements
    
    /// Inserts a key-value pair into the multimap.
    public mutating func insertValue(value: Value, forKey key: Key) {
        insertValues([value], forKey: key)
    }
    
    /// Inserts multiple key-value pairs into the multimap.
    ///
    /// - parameter values: A sequence of values to associate with the given key
    public mutating func insertValues<S:SequenceType where S.Generator.Element == Value>(values: S, forKey key: Key) {
        var result = dictionary[key] ?? []
        let originalSize = result.count
        result += values
        count += result.count - originalSize
        if !result.isEmpty {
            dictionary[key] = result
        }
    }
    
    /// Replaces all the values associated with a given key.
    /// If the key does not exist in the multimap, the values are inserted.
    ///
    /// - parameter values: A sequence of values to associate with the given key
    public mutating func replaceValues<S:SequenceType where S.Generator.Element == Value>(values: S, forKey key: Key) {
        removeValuesForKey(key)
        insertValues(values, forKey: key)
    }
    
    /// Removes a single key-value pair with the given key and value from the multimap, if it exists.
    ///
    /// - returns: The removed value, or nil if no matching pair is found.
    public mutating func removeValue(value: Value, forKey key: Key) -> Value? {
        if var values = dictionary[key] {
            if let removeIndex = values.indexOf(value) {
                let removedValue = values.removeAtIndex(removeIndex)
                count -= 1
                dictionary[key] = values
                return removedValue
            }
            if values.isEmpty {
                dictionary.removeValueForKey(key)
            }
        }
        return nil
    }
    
    /// Removes all values associated with the given key.
    public mutating func removeValuesForKey(key: Key) {
        if let values = dictionary.removeValueForKey(key) {
            count -= values.count
        }
    }
    
    /// Removes all the elements from the multimap, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true) {
        dictionary.removeAll(keepCapacity: keep)
        count = 0
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Internal dictionary holding the elements.
    private var dictionary = [Key: [Value]]()
}

extension Multimap: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality.
    ///
    /// - returns: A generator over the elements.
    public func generate() -> AnyGenerator<(Key,Value)> {
        var keyValueGenerator = dictionary.generate()
        var index = 0
        var pairs = keyValueGenerator.next()
        return AnyGenerator {
            if let tuple = pairs {
                let value = tuple.1[index]
                index += 1
                if index >= tuple.1.count {
                    index = 0
                    pairs = keyValueGenerator.next()
                }
                return (tuple.0, value)
            }
            return nil
        }
    }
}

extension Multimap: DictionaryLiteralConvertible {
    
    // MARK: DictionaryLiteralConvertible Protocol Conformance
    
    /// Constructs a multiset using a dictionary literal.
    /// Unlike a set, multiple copies of an element are inserted.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements)
    }
}

extension Multimap: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the multimap.
    public var description: String {
        return "[" + map{"\($0.0): \($0.1)"}.joinWithSeparator(", ") + "]"
    }
}

extension Multimap: Equatable {
    
}

// MARK: Multimap Equatable Conformance

/// Returns `true` if and only if the multimaps contain the same key-value pairs.
public func ==<Key, Value>(lhs: Multimap<Key, Value>, rhs: Multimap<Key, Value>) -> Bool {
    if lhs.count != rhs.count || lhs.keyCount != rhs.keyCount {
        return false
    }
    for (key, _) in lhs {
        let leftValues = lhs[key]
        var rightValues = rhs[key]
        if leftValues.count != rightValues.count {
            return false
        }
        for element in leftValues {
            if let index = rightValues.indexOf(element) {
                rightValues.removeAtIndex(index)
            }
        }
        if !rightValues.isEmpty {
            return false
        }
    }
    return true
}