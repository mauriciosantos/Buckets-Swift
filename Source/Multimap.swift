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
/// Comforms to `Sequence`, `ExpressibleByDictionaryLiteral`,
/// `Equatable` and `CustomStringConvertible`
public struct Multimap<Key: Hashable, Value: Equatable> {
    
    // MARK: Creating a Multimap
    
    /// Constructs an empty multimap.
    public init() {}
    
    /// Constructs a multimap from a dictionary.
    public init(_ elements: Dictionary<Key, Value>) {
        for (key ,value) in elements {
            insertValue(value, forKey: key)
        }
    }
    
    // MARK: Querying a Multimap
    
    /// Number of key-value pairs stored in the multimap.
    public fileprivate(set) var count = 0
    
    /// Number of distinct keys stored in the multimap.
    public var keyCount: Int {
        return dictionary.count
    }
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// A sequence containing the multimap's unique keys.
    public var keys: AnySequence<Key> {
        return AnySequence(dictionary.keys)
    }
    
    /// A sequence containing the multimap's values.
    public var values: AnySequence<Value> {
        let selfIterator = makeIterator()
        let valueIterator = AnyIterator { selfIterator.next()?.1 }
        return AnySequence(valueIterator)
    }
    
    /// Returns an array containing the values associated with the specified key.
    /// An empty array is returned if the key does not exist in the multimap.
    public subscript(key: Key) -> [Value] {
        if let values = dictionary[key] {
            return values
        }
        return []
    }
    
    /// Returns `true` if the multimap contains at least one key-value pair with the given key.
    public mutating func containsKey(_ key: Key) -> Bool {
        return dictionary[key] != nil
    }
    
    /// Returns `true` if the multimap contains at least one key-value pair with the given key and value.
    public func containsValue(_ value: Value, forKey key: Key) -> Bool {
        if let values = dictionary[key] {
            return values.contains(value)
        }
        return false
    }
    
    // MARK: Accessing and Changing Multimap Elements
    
    /// Inserts a key-value pair into the multimap.
    public mutating func insertValue(_ value: Value, forKey key: Key) {
        insertValues([value], forKey: key)
        
    }
    
    /// Inserts multiple key-value pairs into the multimap.
    ///
    /// - parameter values: A sequence of values to associate with the given key
    public mutating func insertValues<S:Sequence>(_ values: S, forKey key: Key) where S.Iterator.Element == Value {
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
    public mutating func replaceValues<S:Sequence>(_ values: S, forKey key: Key) where S.Iterator.Element == Value {
        removeValuesForKey(key)
        insertValues(values, forKey: key)
    }
    
    /// Removes a single key-value pair with the given key and value from the multimap, if it exists.
    ///
    /// - returns: The removed value, or nil if no matching pair is found.
    @discardableResult
    public mutating func removeValue(_ value: Value, forKey key: Key) -> Value? {
        if var values = dictionary[key] {
            if let removeIndex = values.index(of: value) {
                let removedValue = values.remove(at: removeIndex)
                count -= 1
                dictionary[key] = values
                return removedValue
            }
            if values.isEmpty {
                dictionary.removeValue(forKey: key)
            }
        }
        return nil
    }
    
    /// Removes all values associated with the given key.
    public mutating func removeValuesForKey(_ key: Key) {
        if let values = dictionary.removeValue(forKey: key) {
            count -= values.count
        }
    }
    
    /// Removes all the elements from the multimap, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepingCapacity keep: Bool = true) {
        dictionary.removeAll(keepingCapacity: keep)
        count = 0
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Internal dictionary holding the elements.
    fileprivate var dictionary = [Key: [Value]]()
}

extension Multimap: Sequence {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality.
    ///
    /// - returns: A generator over the elements.
    public func makeIterator() -> AnyIterator<(Key,Value)> {
        var keyValueGenerator = dictionary.makeIterator()
        var index = 0
        var pairs = keyValueGenerator.next()
        return AnyIterator {
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

extension Multimap: ExpressibleByDictionaryLiteral {
    
    // MARK: DictionaryLiteralConvertible Protocol Conformance
    
    /// Constructs a multiset using a dictionary literal.
    /// Unlike a set, multiple copies of an element are inserted.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init()
        for (key, value) in elements {
            insertValue(value, forKey: key)
        }
    }
}

extension Multimap: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the multimap.
    public var description: String {
        return "[" + map{"\($0.0): \($0.1)"}.joined(separator: ", ") + "]"
    }
}

extension Multimap: Equatable {
    
    // MARK: Multimap Equatable Conformance
    
    /// Returns `true` if and only if the multimaps contain the same key-value pairs.
    public static func ==<Key, Value>(lhs: Multimap<Key, Value>, rhs: Multimap<Key, Value>) -> Bool {
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
                if let index = rightValues.index(of: element) {
                    rightValues.remove(at: index)
                }
            }
            if !rightValues.isEmpty {
                return false
            }
        }
        return true
    }
}


