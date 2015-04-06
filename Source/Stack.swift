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
/// Comforms to `SequenceType`, `ArrayLiteralConvertible`,
/// `Printable`, `DebugPrintable` and `ReconstructableSequence`.
public struct Stack<T> {

    // MARK: Properties
    
    /// Number of elements stored in the stack.
    public var count : Int {
        return elements.count
    }
    
    /// `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return elements.isEmpty
    }
    
    /// The top element of the stack, or `nil` if the stack is empty.
    public var top: T? {
        return elements.last
    }
    
    private var elements = [T]()

    // MARK: Creating a Stack
    
    /// Constructs an empty stack.
    public init() {}
    
    /// Constructs a stack from a sequence, such as an array.
    /// The elements will be pushed from first to last.
    public init<S: SequenceType where S.Generator.Element == T>(_ elements: S){
        self.elements = Array(elements)
    }
    
    // MARK: Adding and Removing Elements
    
    /// Inserts an element into the top of the stack.
    public mutating func push(element: T) {
        elements.append(element)
    }
    
    /// Retrieves and removes the top element of the stack.
    ///
    /// :returns: The top element, or `nil` if the stack is empty.
    public mutating func pop() -> T? {
        return !isEmpty ? elements.removeLast() : nil
    }
    
    /// Removes all the elements from the stack, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true)  {
        elements.removeAll(keepCapacity:keep)
    }
}

// MARK: -

extension Stack: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality. Generates elements in LIFO order.
    ///
    /// :returns: A generator over the elements.
    public func generate() -> GeneratorOf<T> {
        let reverseArrayView = lazy(self.elements).reverse()
        return GeneratorOf(IndexingGenerator(reverseArrayView))
    }
}

extension Stack: ArrayLiteralConvertible {
    
    // MARK: ArrayLiteralConvertible Protocol Conformance
    
    /// Constructs a stack using an array literal.
    /// The elements will be pushed from first to last.
    /// `let stack: Stack<Int> = [1,2,3]`
    public init(arrayLiteral elements: T...) {
        self.elements = elements
    }
}

extension Stack: Printable, DebugPrintable {
    
    // MARK: Printable Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the stack.
    public var description: String {
        return "[" + join(", ", map(self) {"\($0)"}) + "]"
    }
    
    // MARK: DebugPrintable Protocol Conformance
    
    /// A string containing a suitable textual representation
    /// of the stack when debugging.
    public var debugDescription: String {
        return description
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

extension Stack: ReconstructableSequence {}
