//
//  Multimap.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/1/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation


public struct Multimap<Key: Hashable, Value: Equatable> {
    
    /// Number of key-value pairs stored in the multimap.
    public private(set) var count = 0
    
    /// Number of keys stored in the Multimap.
    public var keyCount: Int {
        return dictionary.count
    }
    
    /// `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    // Returns a new array containing the key from each key-value pair in this Multimap
    public var keys: Set<Key> {
        return Set(dictionary.keys)
    }
    
    // Returns a new array containing the value from each key-value pair contained in this Multimap, without collapsing duplicates (so values.count == self.count).  Order is not deterministic
    public var values: [Value] {
        var result = [Value]()
        for (k, v) in dictionary {
            result += v
        }
        return result
    }
    
    private var dictionary = [Key:[Value]]()
    
    public init() {}
    
    public init<S:SequenceType where S.Generator.Element == (Key, Value)>(_ elements: S) {
        for (k,value) in elements {
            insertValue(value, forKey: k)
        }
    }
    
    
    // subscript access is preffered
    public func valuesForKey(key: Key) -> [Value] {
            if let values = dictionary[key] {
                return values
            }
            return []
    }
    
    
    public subscript(key: Key) -> [Value] {
        get {
            return valuesForKey(key)
        }
    }
    
    public mutating func containsKey(key: Key) -> Bool {
        return dictionary[key] != nil
    }
    
    // Returns true if this Multimap contains at least one key-value pair with the key key and the value value.
    public func containsValue(value: Value, forKey key: Key) -> Bool {
        if let values = dictionary[key] {
            return contains(values, value)
        }
        return false
    }
    
    public mutating func insertValue(value: Value, forKey key: Key) {
       insertValues([value], forKey: key)
    }
    
    public mutating func insertValues<S:SequenceType where S.Generator.Element == Value>(values: S, forKey key: Key) {
        var result = dictionary[key] ?? []
        for element in values {
            count++
            result.append(element)
        }
        if !result.isEmpty {
            dictionary[key] = result
        }
    }
    
    public mutating func replaceValues<S:SequenceType where S.Generator.Element == Value>(values: S, forKey key: Key) {
        removeValuesForKey(key)
        insertValues(values, forKey: key)
    }
    
    // Removes a single key-value pairs with the key key and the value value from this Multimap, if such exists.
    public mutating func remove(value: Value, forKey key: Key) -> Value? {
        if var values = dictionary[key] {
            var removeIndex: Int?
            for (index, element) in enumerate(values) {
                if element == value {
                    removeIndex = index
                    break
                }
            }
            if let removeIndex = removeIndex {
                let removed = values.removeAtIndex(removeIndex)
                count--
                dictionary[key] = values
                return removed
            }
            if values.isEmpty {
                dictionary.removeValueForKey(key)
            }
        }
        return nil
    }
    
    /// Removes all values associated with the key key.
    public mutating func removeValuesForKey(key: Key) {
        if containsKey(key) {
            count -= dictionary[key]!.count
            dictionary.removeValueForKey(key)
        }
    }
    
    /// Removes all the elements from the multimap, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true) {
        dictionary.removeAll(keepCapacity: keep)
        count = 0
    }
    
}

// MARK: - DictionaryLiteralConvertible

extension Multimap: DictionaryLiteralConvertible {
    
    // MARK: DictionaryLiteralConvertible Protocol Conformance
    
    /// Constructs a multiset using an array literal.
    /// Unlike a set, multiple copies of an element are inserted.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements)
    }
}

// MARK: - SequenceType

extension Multimap: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality
    ///
    /// :returns: A generator over the elements.
    public func generate() -> GeneratorOf<(Key,Value)> {
        var keyValueGenerator = dictionary.generate()
        var index = 0
        var pairs : (Key, [Value])? = keyValueGenerator.next()
        return GeneratorOf<(Key,Value)> {
            if let tuple = pairs {
                let value = tuple.1[index]
                index++
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

// MARK: - Equatable

extension Multimap: Equatable {

}

public func ==<Key, Value>(lhs: Multimap<Key, Value>, rhs: Multimap<Key, Value>) -> Bool {
    if lhs.count != rhs.count || lhs.keyCount != rhs.keyCount   {
        return false
    }
    for (k,v) in lhs {
        var leftValues = lhs[k]
        var rightValues = rhs[k]
        if leftValues.count != rightValues.count {
            return false
        }
        for element in leftValues {
            if let index = find(rightValues, element) {
                rightValues.removeAtIndex(index)
            }
        }
        if !rightValues.isEmpty {
            return false
        }
    }
    return true
}