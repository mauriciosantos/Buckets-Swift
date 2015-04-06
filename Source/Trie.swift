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
/// sequences have a somewhat limited set of possible element values.
/// Trie elements must conform to the `ReconstructableSequence` protocol.
///
/// The operations for insertion, removal, lookup, and prefix matching run in O(n) time,
/// where n is the length of the sequence or prefix.
/// Comforms to `Equatable`, `Hashable`, `Printable` and `DebugPrintable`.
public struct Trie<T: ReconstructableSequence where T.Generator.Element: Hashable> {
    
    typealias Key = T.Generator.Element
    
    /// Empty Sequence of type `T`.
    private let EmptySequence = T([])
    
    // MARK: Properties
    
    /// Number of elements stored in the trie.
    public private(set) var count = 0
    
    /// `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// Reconstructs and returns all the elements stored in the trie.
    public var elements: [T] {
        let emptyGenerator = EmptySequence.generate()
        return reconstructElementsMatchingPrefix(emptyGenerator, lastKeys: [], node: root)
    }
    
    private func reconstructElementsMatchingPrefix(var prefixGenerator: T.Generator, var lastKeys: [Key], node: TrieNode<Key>) -> [T] {
        var result = [T]()
        if let key = node.key {
            lastKeys.append(key)
        }
        if let theKey = prefixGenerator.next(), let nextNode = node.subNodes[theKey] {
            result += reconstructElementsMatchingPrefix(prefixGenerator, lastKeys: lastKeys, node: nextNode)
        } else {
            if node.isEndOfSequence {
                result.append(T(lastKeys))
            }
            for (_, subNode) in node.subNodes {
                result += reconstructElementsMatchingPrefix(prefixGenerator, lastKeys: lastKeys, node: subNode)
            }
        }
        return result
    }
    
    private var root = TrieNode<Key>(key: nil)
    
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
    
    /// Returns `true` if the trie contains the given element
    /// and it's not just a prefix of another element.
    public func contains(element: T) -> Bool {
        let keys = element.generate()
        let nodePair = nodePairForPrefix(keys, node: root, parent: nil)
        return nodePair.endNode?.isEndOfSequence ?? false
    }
    
    private func nodePairForPrefix(var keyGenerator: T.Generator,
        node: TrieNode<Key>, parent: TrieNode<Key>?) -> (endNode: TrieNode<Key>?, parent: TrieNode<Key>?) {
            
            let nextKey: Key! = keyGenerator.next()
            if nextKey == nil {
                return (node, parent)
            }
            
            if let nextNode = node.subNodes[nextKey] {
                return nodePairForPrefix(keyGenerator, node: nextNode, parent: node)
            } else {
                return (nil, node)
            }
    }
    
    /// Returns `true` if the trie contains an element matching the given prefix or if the
    /// given prefix is empty.
    public func containsPrefix(prefix: T) -> Bool {
        let keys = prefix.generate()
        let nodePair = nodePairForPrefix(keys, node: root, parent: nil)
        return nodePair.endNode != nil
    }
    
    /// Returns all the elements in the trie matching the given prefix.
    public func elementsMatchingPrefix(prefix: T) -> [T] {
        let keys = prefix.generate()
        return reconstructElementsMatchingPrefix(keys, lastKeys: [], node: root)
    }
    
    /// Returns the longest prefix in the trie matching the given prefix.
    /// This is not necessarily an inserted element.
    public func longestPrefixMatching(prefix: T) -> T {
        let keys = prefix.generate()
        return longestPrefixMatching(keys, lastKeys:[], node: root)
    }
    
    private func longestPrefixMatching(var keyGenerator: T.Generator,
        var lastKeys: [Key], node: TrieNode<Key>) -> T {
            
            if let key = node.key {
                lastKeys.append(key)
            }
            if let theKey = keyGenerator.next(), let nextNode = node.subNodes[theKey] {
                return longestPrefixMatching(keyGenerator, lastKeys:lastKeys, node: nextNode)
            }
            return T(lastKeys)
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts the given element into the trie.
    ///
    /// :returns: `true` if the trie did not already contain the element.
    public mutating func insert(element: T) -> Bool {
        copyMyself()
        if insert(element.generate(), node: root) {
            count++
            return true
        }
        return false
    }
    
    private func insert(var keyGenerator: T.Generator, node: TrieNode<Key>) -> Bool {
        if let nextKey = keyGenerator.next() {
            let nextNode = node.subNodes[nextKey] ?? TrieNode<Key>(key: nextKey)
            node.subNodes[nextKey] = nextNode
            return insert(keyGenerator, node: nextNode )
        } else {
            let trieWasModified = node.isEndOfSequence != true
            node.isEndOfSequence = true
            return trieWasModified
        }
    }
    
    /// Removes the given element from the trie and returns
    /// it if it was present. This does not affect other members
    /// matching the given element as a prefix.
    public mutating func remove(element: T) -> T? {
        copyMyself()
        let generator = element.generate()
        let nodePair = nodePairForPrefix(generator, node: root, parent: nil)
        
        if let elementNode = nodePair.endNode where elementNode.isEndOfSequence {
            elementNode.isEndOfSequence = false
            if let parentNode = nodePair.parent, let key = elementNode.key where elementNode.subNodes.isEmpty  {
                parentNode.subNodes.removeValueForKey(key)
            }
            return element
        }
        return nil
    }
    
    /// Removes all the elements from the trie.
    public mutating func removeAll() {
        root = TrieNode<Key>(key: nil)
        count = 0
    }
    
    // MARK: Private Helper Methods
    
    /// Cretes a new copy of the root node and all its subnodes if there´s
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
        var copy = TrieNode(key: node.key, isEndOfSequence: node.isEndOfSequence)
        for (key, subNode) in node.subNodes {
            copy.subNodes[key] = deepCopyNode(subNode)
        }
        return copy
    }
}

// MARK: -

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
        result = (31 ^ result) ^ node.isEndOfSequence.hashValue
        result = (31 ^ result) ^ (node.key?.hashValue ?? 0)
        for (_, subNode) in node.subNodes {
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

private func ==<Key>(lhs: TrieNode<Key>, rhs: TrieNode<Key>) -> Bool {
    if lhs.key != rhs.key || lhs.isEndOfSequence != rhs.isEndOfSequence {
        return false
    }
    if lhs.subNodes.count != rhs.subNodes.count {
        return false
    }
    for (key, leftNode) in lhs.subNodes {
        if let rightNode = rhs.subNodes[key] {
            return leftNode == rightNode
        } else {
            return false
        }
    }
    return true
}

// MARK: - TrieNode

private final class TrieNode<Key: Hashable> {
    let key: Key?
    var isEndOfSequence : Bool = false
    var subNodes = [Key : TrieNode<Key>]()
    
    init(key: Key?, isEndOfSequence: Bool = false) {
        self.key = key
        self.isEndOfSequence = isEndOfSequence
    }
}


