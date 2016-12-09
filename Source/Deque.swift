//
//  Dequeue.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/21/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A double-ended queue (deque) is a collection that generalizes a
/// queue, for which elements can be added to or removed from either
/// the front or back.
///
/// The `enqueueFirst`, `enqueueLast`, `dequeueFirst` and `dequeueLast` 
/// operations run in amortized constant time.
///
/// Conforms to `Sequence`, `ExpressibleByArrayLiteral`,
/// `CustomStringConvertible`.
public struct Deque<T> {

    // MARK: Creating a Deque
    
    /// Constructs an empty deque.
    public init() {}
    
    /// Constructs a deque from a sequence, such as an array.
    /// The elements will be enqueued from first to last.
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == T {
        items = CircularArray(elements)
    }
    
    // MARK: Querying a Deque
    
    /// Number of elements stored in the deque.
    public var count : Int {
        return items.count
    }
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// The front element in the deque, or `nil` if the deque is empty.
    public var first: T? {
        return items.first
    }
    
    /// The back element in the deque, or `nil` if the deque is empty.
    public var last: T? {
        return items.last
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts an element into the back of the deque.
    public mutating func enqueueLast(_ element: T) {
        items.append(element)
    }
    
    /// Inserts an element into the front of the deque.
    public mutating func enqueueFirst(_ element: T) {
        items.prepend(element)
    }
    
    /// Retrieves and removes the front element of the deque.
    ///
    /// - returns: The front element, or `nil` if the deque is empty.
    @discardableResult
    public mutating func dequeueFirst() -> T {
        precondition(!isEmpty, "Deque is empty")
        return items.removeFirst()
    }
    
    /// Retrieves and removes the back element of the deque.
    ///
    /// - returns: The back element, or `nil` if the deque is empty.
    @discardableResult
    public mutating func dequeueLast() -> T {
        precondition(!isEmpty, "Deque is empty")
        return items.removeLast()
    }
    
    /// Removes all the elements from the deque, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepingCapacity keep: Bool = false)  {
        items.removeAll(keepingCapacity: keep)
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Internal structure holding the elements.
    fileprivate var items = CircularArray<T>()
}

extension Deque: Sequence {
    
    // MARK: Sequence Protocol Conformance
    
    /// Provides for-in loop functionality. Generates elements in FIFO order.
    ///
    /// - returns: A generator over the elements.
    public func makeIterator() -> AnyIterator<T> {
        return AnyIterator(items.makeIterator())
    }
}

extension Deque: ExpressibleByArrayLiteral {
    
    // MARK: ExpressibleByArrayLiteral Protocol Conformance
    
    /// Constructs a deque using an array literal.
    /// The elements will be enqueued from first to last.
    /// `let deque: Deque<Int> = [1,2,3]`
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

extension Deque: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the deque.
    public var description: String {
        return "[" + map{"\($0)"}.joined(separator: ", ") + "]"
    }
}

// MARK: - Operators

// MARK: Deque Operators

/// Returns `true` if and only if the deques contain the same elements
/// in the same order.
/// The underlying elements must conform to the `Equatable` protocol.
public func ==<U: Equatable>(lhs: Deque<U>, rhs: Deque<U>) -> Bool {
    return lhs.items == rhs.items
}

public func !=<U: Equatable>(lhs: Deque<U>, rhs: Deque<U>) -> Bool {
    return !(lhs==rhs)
}

