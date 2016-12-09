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
///
/// Conforms to `Sequence`, `CustomStringConvertible`.
public struct PriorityQueue<T> {
    
    // MARK: Creating a Priority Queue
    
    /// Constructs an empty priority queue using a closure to
    /// determine the order of a provided pair of elements. The closure that you supply for 
    /// `sortedBy` should return a boolean value to indicate whether one element
    /// should be before (`true`) or after (`false`) another element using strict weak ordering.
    /// See http://en.wikipedia.org/wiki/Weak_ordering#Strict_weak_orderings
    ///
    /// - parameter sortedBy: Strict weak ordering function checking if the first element has higher priority.
    public init(sortedBy sortFunction: @escaping (T,T) -> Bool) {
        self.init([], sortedBy: sortFunction)
    }
    
    /// Constructs a priority queue from a sequence, such as an array, using a given closure to
    /// determine the order of a provided pair of elements. The closure that you supply for
    /// `sortedBy` should return a boolean value to indicate whether one element
    /// should be before (`true`) or after (`false`) another element using strict weak ordering.
    /// See http://en.wikipedia.org/wiki/Weak_ordering#Strict_weak_orderings
    ///
    /// - parameter sortedBy: Strict weak ordering function for checking if the first element has higher priority.
     public init<S: Sequence>(_ elements: S, sortedBy sortFunction: @escaping (T,T) -> Bool) where S.Iterator.Element == T {
        heap = BinaryHeap<T>(compareFunction: sortFunction)
        for e in elements {
            enqueue(e)
        }
    }
    
    // MARK: Querying a Priority Queue
    
    /// Number of elements stored in the priority queue.
    public var count: Int {
        return heap.count
    }
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// The highest priority element in the queue, or `nil` if the queue is empty.
    public var first: T? {
        return heap.max
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts an element into the priority queue.
    public mutating func enqueue(_ element: T) {
        heap.insert(element)
    }
    
    /// Retrieves and removes the highest priority element of the queue.
    ///
    /// - returns: The highest priority element, or `nil` if the queue is empty.
    @discardableResult
    public mutating func dequeue() -> T {
        precondition(!isEmpty, "Queue is empty")
        return heap.removeMax()!
    }
    
    /// Removes all the elements from the priority queue, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepingCapacity keep: Bool = false)  {
        heap.removeAll(keepingCapacity: keep)
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Internal structure holding the elements.
    fileprivate var heap : BinaryHeap<T>
}

extension PriorityQueue: Sequence {
    
    // MARK: Sequence Protocol Conformance
    
    /// Provides for-in loop functionality. Generates elements in no particular order.
    ///
    /// - returns: A generator over the elements.
    public func makeIterator() -> AnyIterator<T> {
        return heap.makeIterator()
    }
}

extension PriorityQueue: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the priority queue.
    public var description: String {
        return "[" + map{"\($0)"}.joined(separator: ", ") + "]"
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



