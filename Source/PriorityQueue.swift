//
//  PriorityQueue.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/19/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

public struct PriorityQueue<T> {
    
    public var isEmpty: Bool {
        return count == 0
    }
    public var count: Int {
        return heap.count
    }
    public var first: T? {
        return heap.max
    }
    
    private var heap : BinaryHeap<T>
    
    public init(compareFunction: (T,T) -> Bool) {
        self.init(compareFunction:compareFunction, elements:[])
    }
    
    public init(compareFunction: (T,T) -> Bool, elements: [T]) {
        heap = BinaryHeap<T>(compareFunction)
        for e in elements {
            enqueue(e)
        }
    }
    
    public mutating func enqueue(element: T) {
        heap.insert(element)
    }
    
    public mutating func dequeue() -> T? {
        return heap.removeMax()
    }
    
    public mutating func removeAll(keepCapacity keep: Bool = true)  {
        heap.removeAll(keepCapacity: keep)
    }
}

// MARK: - SequenceType

extension PriorityQueue: SequenceType {
    
    // In no particular order
    public func generate() -> GeneratorOf<T> {
        return heap.generate()
    }
}



