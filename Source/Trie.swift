//
//  Trie.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/26/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

public struct Trie<T: SequenceType where T.Generator.Element: Hashable> {
    
    typealias ElementType = T.Generator.Element
    
    private var root = TrieNode<T>(element: nil, completeSequence: nil)
    
    public var sequences: [T] {
        return getAllSequences(root)
    }
    
    public init() {}
    
    public mutating func insertSequence(sequence: T) {
        copyMyself()
        insertSequence(sequence, elementGenerator:sequence.generate(), node: root)
    }
    
    public func hasPrefix(prefix: T) -> Bool {
        return lastNodeOfPrefix(prefix) != nil
    }
    
    public func containsSequence(sequence: T) -> Bool {
        return lastNodeOfPrefix(sequence)?.isEndOfSequence ?? false
    }
    
    public func allSequences() -> [T] {
        var sequences = [T]()
        var currentSequence = [ElementType]()
        return sequences
    }
    
    private func getAllSequences(node: TrieNode<T>) -> [T] {
        var result = [T]()
        for (_,v) in node.subNodes {
            if let sequence = v.completeSequence {
                result.append(sequence)
            }
            result += getAllSequences(v)
        }
        return result
    }
    
    
    private func lastNodeOfPrefix(prefix: T) -> TrieNode<T>? {
        var nodes = root.subNodes
        var lastNode : TrieNode<T>? = nil
        for element in prefix {
            lastNode = nodes[element]
            if let lastNode = lastNode {
                nodes = lastNode.subNodes
            } else {
                return nil
            }
        }
        return lastNode
    }
    
    private mutating func insertSequence(sequence: T, var elementGenerator: T.Generator, node: TrieNode<T>) -> Bool {
        let nextElement = elementGenerator.next()
        if nextElement == nil {
            return true
        }
        
        let nextNode: TrieNode<T>
        if node.subNodes[nextElement!] == nil {
            nextNode = TrieNode<T>(element: nextElement!, completeSequence: nil)
        }
        else {
            nextNode = node.subNodes[nextElement!]!
        }
        
        let isComplete = insertSequence(sequence, elementGenerator:elementGenerator, node: nextNode)
        node.subNodes[nextElement!] = nextNode
        
        if isComplete {
            nextNode.completeSequence = sequence
        }
        
        return false
    }
    
    private mutating func copyMyself() {
        if !isUniquelyReferencedNonObjC(&root) {
            root = root.copy()
        }
    }
}

private final class TrieNode<T: SequenceType where T.Generator.Element: Hashable> {
    
    typealias ElementType = T.Generator.Element
    
    var completeSequence: T?
    var element: ElementType?
    var subNodes = [ElementType : TrieNode<T>]()
    
    var isEndOfSequence : Bool {
        return completeSequence != nil
    }
    
    init(element: ElementType?, completeSequence: T?){
        self.completeSequence = completeSequence
        self.element = element
    }
    
    func copy() -> TrieNode<T> {
        var selfCopy = TrieNode(element: element, completeSequence: completeSequence)
        for (k,v) in subNodes {
            selfCopy.subNodes[k] = v.copy()
        }
        return selfCopy
    }
}