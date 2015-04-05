//
//  Queue.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/19/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A queue is a First-In-First-Out (FIFO) collection, 
/// the first element added to the queue will be the first one 
/// to be removed.
///
/// The `enqueue` and `dequeue` operations run in amortized constant time.
/// Comforms to `SequenceType`, `ArrayLiteralConvertible`,
/// `Printable`, `DebugPrintable` and `ReconstructableSequence`.
public struct Queue<T> {
    
    private var items = CircularArray<T>()
    
    // MARK: Properties
    
    /// Number of elements stored in the queue.
    public var count : Int {
        return items.count
    }
    
    /// `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// The front element in the queue, or `nil` if the queue is empty.
    public var first: T? {
        return items.first
    }
    
    // MARK: Creating a Queue
    
    /// Constructs an empty queue.
    public init() {}
    
    /// Constructs a queue from a sequence, such as an array.
    /// The elements will be enqueued from first to last.
    public init<S: SequenceType where S.Generator.Element == T>(_ elements: S){
        items = CircularArray(elements)
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts an element into the back of the queue.
    public mutating func enqueue(element: T) {
        items.append(element)
    }
    
    /// Retrieves and removes the front element of the queue.
    ///
    /// :returns: The front element, or `nil` if the queue is empty.
    public mutating func dequeue() -> T? {
        return items.removeFirst()
    }
    
    /// Removes all the elements from the queue, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true)  {
        items.removeAll(keepCapacity: keep)
    }
}

// MARK: -

extension Queue: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality. Generates elements in FIFO order.
    ///
    /// :returns: A generator over the elements.
    public func generate() -> GeneratorOf<T> {
        return items.generate()
    }
}

extension Queue: ArrayLiteralConvertible {
    
    // MARK: ArrayLiteralConvertible Protocol Conformance
    
    /// Constructs a queue using an array literal.
    /// The elements will be enqueued from first to last.
    /// `let queue: Queue<Int> = [1,2,3]`
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

extension Queue: Printable, DebugPrintable {
    
    // MARK: Printable Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the queue.
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

// MARK: -

// MARK: Queue Operators

/// Returns `true` if and only if the queues contain the same elements
/// in the same order.
/// The underlying elements must conform to the `Equatable` protocol.
public func ==<U: Equatable>(lhs: Queue<U>, rhs: Queue<U>) -> Bool {
    return lhs.items == rhs.items
}

public func !=<U: Equatable>(lhs: Queue<U>, rhs: Queue<U>) -> Bool {
    return !(lhs==rhs)
}

extension Queue: ReconstructableSequence {}
