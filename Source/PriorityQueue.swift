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
        self.init(elements: [], compareFunction: compareFunction)
    }
    
    public init(elements: [T], compareFunction: (T,T) -> Bool) {
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

// MARK: - Printable

extension PriorityQueue: Printable, DebugPrintable {
    
    // MARK: Printable Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the priority queue.
    public var description: String {
        return "[" + join(", ", map(self) {"\($0)"}) + "]"
    }
    
    // MARK: DebugPrintable Protocol Conformance
    
    /// A string containing a suitable textual representation
    /// of the queue when debugging.
    public var debugDescription: String {
        return description
    }
}

// MARK: - Operators

// MARK: Priority Queue Operators

/// Returns `true` if and only if the queues contain the same elements
/// in the same order.
/// The underlying elements must conform to the `Equatable` protocol.
public func ==<U: Equatable>(lhs: PriorityQueue<U>, rhs: PriorityQueue<U>) -> Bool {
    return lhs.heap == rhs.heap
}

public func !=<U: Equatable>(lhs: PriorityQueue<U>, rhs: PriorityQueue<U>) -> Bool {
    return !(lhs==rhs)
}



