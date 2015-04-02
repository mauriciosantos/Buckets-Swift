//
//  PriorityQueue.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/19/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// In a priority queue each element is associated with a "priority", 
/// elements are dequeued in highest-priority-first order (the
/// elements with the highest priority are dequeued first).
///
/// The `enqueue` and `dequeue` operations run in O(log(n)) time.
/// Comforms to `SequenceType`, `Printable` and `DebugPrintable`.
public struct PriorityQueue<T> {
    
    // MARK: Properties
    
    /// Number of elements stored in the priority queue.
    public var count: Int {
        return heap.count
    }
    
    /// `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// The highest priority element in the queue, or `nil` if the queue is empty.
    public var first: T? {
        return heap.max
    }
    
    private var heap : BinaryHeap<T>
    
    // MARK: Creating a Priority Queue
    
    /// Constructs an empty priority queue of type `T` using a given closure to
    /// determine the order of a provided pair of elements. The closure that you supply for 
    /// `isOrderedBefore` should return a Boolean value to indicate whether one element 
    /// should be before (`true`) or after (`false`) another element.
    ///
    /// :param: isOrderedBefore Function to check if the first element has higher priority.
    public init(_ isOrderedBefore: (T,T) -> Bool) {
        self.init(elements: [], isOrderedBefore: isOrderedBefore)
    }
    
    /// Constructs a priority queue from a sequence, such as an array, using a given closure to
    /// determine the order of a provided pair of elements. The closure that you supply for
    /// `isOrderedBefore` should return a Boolean value to indicate whether one element
    /// should be before (`true`) or after (`false`) another element.
    ///
    /// :param: isOrderedBefore Function to check if the first element has higher priority.
     public init<S: SequenceType where S.Generator.Element == T>(elements: S, isOrderedBefore: (T,T) -> Bool) {
        heap = BinaryHeap<T>(compareFunction: isOrderedBefore)
        for e in elements {
            enqueue(e)
        }
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts an element into the priority queue.
    public mutating func enqueue(element: T) {
        heap.insert(element)
    }
    
    /// Retrieves and removes the highest priority element of the queue.
    ///
    /// :returns: The highest priority element, or `nil` if the queue is empty.
    public mutating func dequeue() -> T? {
        return heap.removeMax()
    }
    
    /// Removes all the elements from the priority queue, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true)  {
        heap.removeAll(keepCapacity: keep)
    }
}

// MARK: - SequenceType

extension PriorityQueue: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality. Generates elements in no particular order.
    ///
    /// :returns: A generator over the elements.
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

/// Returns `true` if and only if the priority queues contain the same elements
/// in the same order.
/// The underlying elements must conform to the `Equatable` protocol.
public func ==<U: Equatable>(lhs: PriorityQueue<U>, rhs: PriorityQueue<U>) -> Bool {
    return lhs.heap == rhs.heap
}

public func !=<U: Equatable>(lhs: PriorityQueue<U>, rhs: PriorityQueue<U>) -> Bool {
    return !(lhs==rhs)
}



