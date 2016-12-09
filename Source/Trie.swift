//
//  Trie.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/26/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A Trie (sometimes called a prefix tree) is used for storing a set of
/// strings compactly and searching for full words or partial prefixes very efficiently.
///
/// The operations for insertion, removal, lookup, and prefix matching run in O(n) time,
/// where n is the length of the sequence or prefix.
///
/// Conforms to `CustomStringConvertible`, `Hashable`.
public struct Trie {
    
    // MARK: Creating a Trie
    
    /// Constructs an empty Trie.
    public init() {}
    
    /// Constructs a trie from a sequence, such as an array. Inserts all the elements
    /// from the given sequence into the trie.
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == String {
        for e in elements {
            insert(e)
        }
    }
    
    // MARK: Querying a Trie
    
    /// Number of words stored in the trie.
    public fileprivate(set) var count = 0
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// Reconstructs and returns all the words stored in the trie.
    public var elements: [String] {
        var emptyGenerator = "".characters.makeIterator()
        var result = [String]()
        var lastKeys = [Character]()
        result.reserveCapacity(count)
        findPrefix(&emptyGenerator, charStack: &lastKeys, result: &result, node: root)
        return result
    }
    
    /// Returns `true` if the trie contains the given word
    /// and it's not just a prefix of another word.
    public func contains(_ word: String) -> Bool {
        var keys = word.characters.makeIterator()
        let nodePair = nodePairForPrefix(&keys, node: root, parent: nil)
        return nodePair.endNode?.isWord ?? false
    }
    
    /// Returns `true` if the trie contains at least one word matching the given prefix or if the
    /// given prefix is empty.
    public func isPrefix(_ prefix: String) -> Bool {
        var keys = prefix.characters.makeIterator()
        let nodePair = nodePairForPrefix(&keys, node: root, parent: nil)
        return nodePair.endNode != nil
    }
    
    /// Returns all the words in the trie matching the given prefix.
    public func findPrefix(_ prefix: String) -> [String] {
        var prefixKeys = prefix.characters.makeIterator()
        var result = [String]()
        var lastKeys = [Character]()
        findPrefix(&prefixKeys, charStack: &lastKeys, result:&result, node: root)
        return result
    }
    
    /// Returns the longest prefix in the trie matching the given word.
    /// The returned value is not necessarily a full word in the trie.
    public func longestPrefixIn(_ element: String) -> String {
        var keys = element.characters.makeIterator()
        return longestPrefixIn(&keys, lastChars:[], node: root)
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts the given word into the trie.
    ///
    /// - returns: `true` if the trie did not already contain the word.
    @discardableResult
    public mutating func insert(_ word: String) -> Bool {
        if !contains(word) {
            copyMyself()
            var keyGenerator = word.characters.makeIterator()
            if insert(&keyGenerator, node: root) {
                count += 1
                return true
            }
        }
        return false
    }
    
    /// Removes the given word from the trie and returns
    /// it if it was present. This does not affect other words
    /// matching the given word as a prefix.
    @discardableResult
    public mutating func remove(_ word: String) -> String? {
        if contains(word) {
            copyMyself()
            var generator = word.characters.makeIterator()
            let nodePair = nodePairForPrefix(&generator, node: root, parent: nil)
            
            if let elementNode = nodePair.endNode , elementNode.isWord {
                elementNode.isWord = false
                if let parentNode = nodePair.parent, let key = elementNode.key
                    , elementNode.children.isEmpty  {
                        parentNode.children.removeValue(forKey: key)
                }
                count -= 1
                return word
            }
        }
        return nil
    }
    
    /// Removes all the words from the trie.
    public mutating func removeAll() {
        root = TrieNode(key: nil)
        count = 0
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// The root node containing an empty word.
    fileprivate var root = TrieNode(key: nil)
    
    /// Returns the node containing the last key of the prefix and its parent.
    fileprivate func nodePairForPrefix(_ charGenerator: inout IndexingIterator<String.CharacterView>,
        node: TrieNode,
        parent: TrieNode?) -> (endNode: TrieNode?, parent: TrieNode?) {
            
        let nextChar: Character! = charGenerator.next()
        if nextChar == nil {
            return (node, parent)
        }
        
        if let nextNode = node.children[nextChar] {
            return nodePairForPrefix(&charGenerator, node: nextNode, parent: node)
        } else {
            return (nil, node)
        }
    }
    
    fileprivate func findPrefix(_ prefixGenerator: inout IndexingIterator<String.CharacterView>,
        charStack: inout [Character], result: inout [String], node: TrieNode) {
        
        if let key = node.key {
            charStack.append(key)
        }
        if let theKey = prefixGenerator.next() {
            if let nextNode = node.children[theKey] {
                findPrefix(&prefixGenerator, charStack: &charStack, result:&result, node: nextNode)
            }
        } else {
            if node.isWord {
                result.append(String(charStack))
            }
            for subNode in node.children.values {
                findPrefix(&prefixGenerator, charStack: &charStack, result:&result, node: subNode)
            }
        }
        if let _ = node.key {
            charStack.removeLast()
        }
    }
    
    fileprivate func longestPrefixIn(_ keyGenerator: inout IndexingIterator<String.CharacterView>,
        lastChars: [Character], node: TrieNode) -> String {
        let chars: [Character]
        if let key = node.key {
            chars = lastChars + [key]
        } else {
            chars = lastChars
        }
        if let theKey = keyGenerator.next(), let nextNode = node.children[theKey] {
            return longestPrefixIn(&keyGenerator, lastChars:chars, node: nextNode)
        }
        return String(chars)
    }
    
    fileprivate func insert(_ keyGenerator: inout IndexingIterator<String.CharacterView>, node: TrieNode) -> Bool {
        if let nextKey = keyGenerator.next() {
            let nextNode = node.children[nextKey] ?? TrieNode(key: nextKey)
            node.children[nextKey] = nextNode
            return insert(&keyGenerator, node: nextNode )
        } else {
            let trieWasModified = node.isWord != true
            node.isWord = true
            return trieWasModified
        }
    }
    
    /// Creates a new copy of the root node and all its sub nodes if there´s
    /// more than one strong reference pointing to the root node.
    ///
    /// The Trie itself is a value type but a TrieNode is a reference type,
    /// calling this method ensures copy-on-write behavior.
    fileprivate mutating func copyMyself() {
        if !isKnownUniquelyReferenced(&root) {
            root = deepCopyNode(root)
        }
    }
    
    fileprivate func deepCopyNode(_ node: TrieNode) -> TrieNode {
        let copy = TrieNode(key: node.key, isWord: node.isWord)
        for (key, subNode) in node.children {
            copy.children[key] = deepCopyNode(subNode)
        }
        return copy
    }
}

extension Trie: CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the trie.
    public var description: String {
        return "[" + elements.map {"\($0)"}.joined(separator: ", ") + "]"
    }
    
    // MARK: CustomDebugStringConvertible Protocol Conformance
    
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
    
    fileprivate func hashValue(_ node: TrieNode) -> Int {
        var result = 71
        result = (31 ^ result) ^ node.isWord.hashValue
        result = (31 ^ result) ^ (node.key?.hashValue ?? 0)
        for (_, subNode) in node.children {
            result = (31 ^ result) ^ hashValue(subNode)
        }
        return result
    }
}

// MARK: Trie Equatable Conformance

/// Returns `true` if and only if the tries contain the same elements.
public func ==(lhs: Trie, rhs: Trie) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    return lhs.root == rhs.root
}


// MARK: - TrieNode

private class TrieNode: Equatable {
    let key: Character?
    var isWord : Bool = false
    var children = [Character : TrieNode]()
    
    init(key: Character?, isWord: Bool = false) {
        self.key = key
        self.isWord = isWord
    }
}

private func ==(lhs: TrieNode, rhs: TrieNode) -> Bool {
    if lhs.key != rhs.key || lhs.isWord != rhs.isWord
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
