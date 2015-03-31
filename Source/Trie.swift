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
    
    private var subNodes = [ElementType : TrieNode<T>]()
    private var tag = Tag()
    
    public var sequences: [T] {
        var result = [T]()
        getAllSequences(self.subNodes, result:  &result)
        return result
    }
    
    public init() {}
    
    public mutating func insertSequence(sequence: T) {
        copyMyself()
        var generator = sequence.generate()
        let firstElement = generator.next()
        insertSequence(sequence, element: firstElement, generator:&generator, nodes: &self.subNodes)
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
    
    private func getAllSequences(nodes: [ElementType : TrieNode<T>], inout result: [T]) {
        for (_,v) in nodes {
            if let sequence = v.completeSequence {
                result.append(sequence)
            }
            getAllSequences(v.subNodes, result: &result)
        }
    }
    
    
    private func lastNodeOfPrefix(prefix: T) -> TrieNode<T>? {
        var nodes = subNodes
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
    
    private mutating func insertSequence(sequence: T, element: ElementType!, inout generator: T.Generator,
        inout nodes: [ElementType : TrieNode<T>]) {
        
        if element == nil {
            return
        }
        
        let nextElement = generator.next()
        let fullSequence: T? = nextElement == nil ? sequence : nil
        
        if nodes[element] == nil {
            var node = TrieNode<T>(element: element, completeSequence: fullSequence)
            insertSequence(sequence, element: nextElement, generator:&generator, nodes: &node.subNodes)
            nodes[element] = node
        }
        else {
            nodes[element]!.completeSequence = nodes[element]!.isEndOfSequence ? nodes[element]!.completeSequence : fullSequence
            insertSequence(sequence, element: nextElement, generator:&generator, nodes: &nodes[element]!.subNodes)
        }
    }
    
    private mutating func copyMyself() {
        if isUniquelyReferencedNonObjC(&tag) {
            return
        }
        tag = Tag()
        var newNodes = [ElementType : TrieNode<T>]()
        for (k,v) in subNodes {
            newNodes[k] = v.copy()
        }
        subNodes = newNodes
    }
}

// Class to detect unique reference and implement copy on write
private class Tag {
    
}

private class TrieNode<T: SequenceType where T.Generator.Element: Hashable> {
    
    typealias ElementType = T.Generator.Element
    
    var completeSequence: T?
    var element: ElementType
    var subNodes = [ElementType : TrieNode<T>]()
    
    var isEndOfSequence : Bool {
        return completeSequence != nil
    }
    
    init(element: ElementType, completeSequence: T? = nil){
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