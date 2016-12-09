//
//  Stack.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/19/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A Stack is a Last-In-First-Out (LIFO) collection,
/// the last element added to the stack will be the first one to be removed.
///
/// The `push` and `pop` operations run in amortized constant time.
///
/// Conforms to `Sequence`, `ExpressibleByArrayLiteral`,
/// `CustomStringConvertible`.
public struct Stack<T> {

    // MARK: Creating a Stack
    
    /// Constructs an empty stack.
    public init() {}
    
    /// Constructs a stack from a sequence, such as an array.
    /// The elements will be pushed from first to last.
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == T {
        self.elements = Array(elements)
    }
    
    // MARK: Querying a Stack
    
    /// Number of elements stored in the stack.
    public var count : Int {
        return elements.count
    }
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return elements.isEmpty
    }
    
    /// The top element of the stack, or `nil` if the stack is empty.
    public var top: T? {
        return elements.last
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts an element into the top of the stack.
    public mutating func push(_ element: T) {
        elements.append(element)
    }
    
    /// Retrieves and removes the top element of the stack.
    ///
    /// - returns: The top element.
    @discardableResult
    public mutating func pop() -> T {
        precondition(!isEmpty, "Stack is empty")
        return elements.removeLast()
    }
    
    /// Removes all the elements from the stack, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepingCapacity keep: Bool = false)  {
        elements.removeAll(keepingCapacity:keep)
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Internal structure holding the elements.
    fileprivate var elements = [T]()
}


extension Stack: Sequence {
    
    // MARK: Sequence Protocol Conformance
    
    /// Provides for-in loop functionality. Generates elements in LIFO order.
    ///
    /// - returns: A generator over the elements.
    public func makeIterator() -> AnyIterator<T> {
        let reversed: ReversedRandomAccessCollection<[T]> = elements.reversed()
        return AnyIterator(reversed.makeIterator())
    }
}

extension Stack: ExpressibleByArrayLiteral {
    
    // MARK: ExpressibleByArrayLiteral Protocol Conformance
    
    /// Constructs a stack using an array literal.
    /// The elements will be pushed from first to last.
    /// `let stack: Stack<Int> = [1,2,3]`
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

extension Stack: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the stack.
    public var description: String {
        return "[" + map{"\($0)"}.joined(separator: ", ") + "]"
    }
}

// MARK: - Operators

// MARK: Stack Operators

/// Returns `true` if and only if the stacks contain the same elements
/// in the same order.
/// The underlying elements must conform to the `Equatable` protocol.
public func ==<U: Equatable>(lhs: Stack<U>, rhs: Stack<U>) -> Bool {
    return lhs.elements == rhs.elements
}

public func !=<U: Equatable>(lhs: Stack<U>, rhs: Stack<U>) -> Bool {
    return !(lhs == rhs)
}
