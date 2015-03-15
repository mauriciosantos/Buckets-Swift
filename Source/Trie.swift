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
    
    private var roots : [ElementType : TrieNode<T>] = [:]
    
    public var sequences: [T] {
        var result = [T]()
        getAllSequences(self.roots, result:  &result)
        return result
    }
    
    public init() {}
    
    public mutating func insertSequence(sequence: T) {
        var generator = sequence.generate()
        let firstElement = generator.next()
        insertSequence(sequence, element: firstElement, generator:&generator, nodes: &self.roots)
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
        var nodes = roots
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
}


private struct TrieNode<T: SequenceType where T.Generator.Element: Hashable> {
    
    typealias ElementType = T.Generator.Element
    
    // Ugly! - required for recursive generic structs
    var privateSequence: Any?
    var privateElement: Any
    
    var completeSequence: T? {
        get {return privateSequence as T?}
        set {privateSequence = newValue}
    }
    var element: ElementType {
        get {return privateElement as ElementType}
        set {privateElement = newValue}
    }
    
    var subNodes = [ElementType : TrieNode<T>]()
    
    var isEndOfSequence : Bool {
        return completeSequence != nil
    }
    
    init(element: ElementType, completeSequence: T? = nil){
        self.privateSequence = completeSequence
        self.privateElement = element
    }
}