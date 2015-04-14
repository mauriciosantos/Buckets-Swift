//
//  Trie.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/26/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A Trie (sometimes called a prefix tree) is used for storing a set of
/// sequences compactly and searching for full sequences or partial prefixes very efficiently.
/// It is commonly used with strings, but it's not mandatory. However, it is recommended that
/// sequences have a somewhat limited set of values.
///
/// Trie elements must conform to the `ReconstructableSequence` protocol.
/// Types already conforming to the protocol include, but are not limited to: `String`, `Array`, 
/// `CircularArray`, `BitArray`, `Queue`, `Deque` and `Stack`.
///
/// The operations for insertion, removal, lookup, and prefix matching run in O(n) time,
/// where n is the length of the sequence or prefix.
///
/// Conforms to `Equatable`, `Hashable`, `Printable` and `DebugPrintable`.
public struct Trie<T: ReconstructableSequence where T.Generator.Element: Hashable> {
    
    typealias Key = T.Generator.Element
    
    // MARK: Creating a Trie
    
    /// Constructs an empty Trie.
    public init() {}
    
    /// Constructs a trie from a sequence, such as an array. Inserts all the elements
    /// from the given sequence into the trie.
    public init<S: SequenceType where S.Generator.Element == T>(_ elements: S){
        for e in elements {
            insert(e)
        }
    }
    
    // MARK: Querying a Trie
    
    /// Number of elements stored in the trie.
    public private(set) var count = 0
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// Reconstructs and returns all the elements stored in the trie.
    public var elements: [T] {
        var emptyGenerator = T(EmptyGenerator()).generate()
        var result = [T]()
        var lastKeys = [Key]()
        result.reserveCapacity(count)
        findPrefix(&emptyGenerator, keyStack: &lastKeys, result: &result, node: root)
        return result
    }
    
    /// Returns `true` if the trie contains the given element
    /// and it's not just a prefix of another element.
    public func contains(element: T) -> Bool {
        var keys = element.generate()
        let nodePair = nodePairForPrefix(&keys, node: root, parent: nil)
        return nodePair.endNode?.isFinal ?? false
    }
    
    /// Returns `true` if the trie contains at least one element matching the given prefix or if the
    /// given prefix is empty.
    public func isPrefix(prefix: T) -> Bool {
        var keys = prefix.generate()
        let nodePair = nodePairForPrefix(&keys, node: root, parent: nil)
        return nodePair.endNode != nil
    }
    
    /// Returns all the elements in the trie matching the given prefix.
    public func findPrefix(prefix: T) -> [T] {
        var prefixKeys = prefix.generate()
        var result = [T]()
        var lastKeys = [Key]()
        findPrefix(&prefixKeys, keyStack: &lastKeys, result:&result, node: root)
        return result
    }
    
    /// Returns the longest prefix in the trie matching the given element.
    /// The returned value is not necessarily a full inserted element.
    public func longestPrefixIn(element: T) -> T {
        var keys = element.generate()
        return longestPrefixIn(&keys, lastKeys:[], node: root)
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts the given element into the trie.
    ///
    /// :returns: `true` if the trie did not already contain the element.
    public mutating func insert(element: T) -> Bool {
        if !contains(element) {
            copyMyself()
            var keyGenerator = element.generate()
            if insert(&keyGenerator, node: root) {
                count++
                return true
            }
        }
        return false
    }
    
    /// Removes the given element from the trie and returns
    /// it if it was present. This does not affect other members
    /// matching the given element as a prefix.
    public mutating func remove(element: T) -> T? {
        if contains(element) {
            copyMyself()
            var generator = element.generate()
            let nodePair = nodePairForPrefix(&generator, node: root, parent: nil)
            
            if let elementNode = nodePair.endNode where elementNode.isFinal {
                elementNode.isFinal = false
                if let parentNode = nodePair.parent, key = elementNode.key
                    where elementNode.children.isEmpty  {
                        parentNode.children.removeValueForKey(key)
                }
                count--
                return element
            }
        }
        return nil
    }
    
    /// Removes all the elements from the trie.
    public mutating func removeAll() {
        root = TrieNode<Key>(key: nil)
        count = 0
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// The root node containing an empty sequence.
    private var root = TrieNode<Key>(key: nil)
    
    /// Returns the node containing the last key of the prefix and its parent.
    private func nodePairForPrefix(inout keyGenerator: T.Generator, node: TrieNode<Key>,
        parent: TrieNode<Key>?) -> (endNode: TrieNode<Key>?, parent: TrieNode<Key>?) {
            
        let nextKey: Key! = keyGenerator.next()
        if nextKey == nil {
            return (node, parent)
        }
        
        if let nextNode = node.children[nextKey] {
            return nodePairForPrefix(&keyGenerator, node: nextNode, parent: node)
        } else {
            return (nil, node)
        }
    }
    
    private func findPrefix(inout prefixGenerator: T.Generator,
        inout keyStack: [Key], inout result: [T], node: TrieNode<Key>) {
        
        if let key = node.key {
            keyStack.append(key)
        }
        if let theKey = prefixGenerator.next() {
            if let nextNode = node.children[theKey] {
                findPrefix(&prefixGenerator, keyStack: &keyStack, result:&result, node: nextNode)
            }
        } else {
            if node.isFinal {
                result.append(T(keyStack))
            }
            for subNode in node.children.values {
                findPrefix(&prefixGenerator, keyStack: &keyStack, result:&result, node: subNode)
            }
        }
        if let key = node.key {
            keyStack.removeLast()
        }
    }
    
    private func longestPrefixIn(inout keyGenerator: T.Generator,
        var lastKeys: [Key], node: TrieNode<Key>) -> T {
            
        if let key = node.key {
            lastKeys.append(key)
        }
        if let theKey = keyGenerator.next(), nextNode = node.children[theKey] {
            return longestPrefixIn(&keyGenerator, lastKeys:lastKeys, node: nextNode)
        }
        return T(lastKeys)
    }
    
    private func insert(inout keyGenerator: T.Generator, node: TrieNode<Key>) -> Bool {
        if let nextKey = keyGenerator.next() {
            let nextNode = node.children[nextKey] ?? TrieNode<Key>(key: nextKey)
            node.children[nextKey] = nextNode
            return insert(&keyGenerator, node: nextNode )
        } else {
            let trieWasModified = node.isFinal != true
            node.isFinal = true
            return trieWasModified
        }
    }
    
    /// Creates a new copy of the root node and all its sub nodes if there´s
    /// more than one strong reference pointing to the root node.
    ///
    /// The Trie itself is a value type but a TrieNode is a reference type,
    /// calling this method ensures copy-on-write behavior.
    private mutating func copyMyself() {
        if !isUniquelyReferencedNonObjC(&root) {
            root = deepCopyNode(root)
        }
    }
    
    private func deepCopyNode(node: TrieNode<Key>) -> TrieNode<Key> {
        var copy = TrieNode(key: node.key, isFinal: node.isFinal)
        for (key, subNode) in node.children {
            copy.children[key] = deepCopyNode(subNode)
        }
        return copy
    }
}

extension Trie: Printable, DebugPrintable {
    
    // MARK: Printable Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the trie.
    public var description: String {
        return "[" + join(", ", map(elements) {"\($0)"}) + "]"
    }
    
    // MARK: DebugPrintable Protocol Conformance
    
    /// A string containing a suitable textual representation
    /// of the trie when debugging.
    public var debugDescription: String {
        return description
    }
}

extension Trie: Hashable {
    
    // MARK: Hashable Protocol Conformance
    
    /// The hash value.
    /// `x == y` implies `x.hashValue == y.hashValue`
    public var hashValue: Int {
        return hashValue(root)
    }
    
    private func hashValue(node: TrieNode<Key>) -> Int {
        var result = 71
        result = (31 ^ result) ^ node.isFinal.hashValue
        result = (31 ^ result) ^ (node.key?.hashValue ?? 0)
        for (_, subNode) in node.children {
            result = (31 ^ result) ^ hashValue(subNode)
        }
        return result
    }
}

// MARK:- Trie Equatable Conformance

/// Returns `true` if and only if the tries contain the same elements.
public func ==<T>(lhs: Trie<T>, rhs: Trie<T>) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    return lhs.root == rhs.root
}


// MARK: - TrieNode

private class TrieNode<Key: Hashable>: Equatable {
    let key: Key?
    var isFinal : Bool = false
    var children = [Key : TrieNode<Key>]()
    
    init(key: Key?, isFinal: Bool = false) {
        self.key = key
        self.isFinal = isFinal
    }
}

private func ==<Key>(lhs: TrieNode<Key>, rhs: TrieNode<Key>) -> Bool {
    if lhs.key != rhs.key || lhs.isFinal != rhs.isFinal
        || lhs.children.count != rhs.children.count  {
        return false
    }
    for (key, leftNode) in lhs.children {
        if leftNode != rhs.children[key] {
            return false
        }
    }
    return true
}


