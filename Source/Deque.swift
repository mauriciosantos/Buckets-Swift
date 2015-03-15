//
//  Dequeue.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/21/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

public struct Deque<T> {
    
    private var items = CircularArray<T>()
    
    public var isEmpty: Bool {
        return count == 0
    }
    public var first: T? {
        return items.first
    }
    public var last: T? {
        return items.last
    }
    public var count : Int {
        return items.count
    }
    
    public init() {}
    
    public mutating func enqueueLast(element: T) {
        items.append(element)
    }
    
    public mutating func enqueueFirst(element: T) {
        items.prepend(element)
    }
    
    public mutating func dequeueFirst() -> T? {
        return items.removeFirst()
    }
    
    public mutating func dequeueLast() -> T? {
        return items.removeLast()
    }
    
    public mutating func removeAll(keepCapacity keep: Bool = true)  {
        items.removeAll(keepCapacity: keep)
    }    
}

// MARK: - SequenceType

extension Deque: SequenceType {
    public func generate() -> GeneratorOf<T> {
        return items.generate()
    }
}

// MARK: - ArrayLiteralConvertible

extension Deque: ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        for element in elements {
            enqueueLast(element)
        }
    }
}

// MARK: - Operators

public func ==<U: Equatable>(lhs: Deque<U>, rhs: Deque<U>) -> Bool {
    return lhs.items == rhs.items
}

public func !=<U: Equatable>(lhs: Deque<U>, rhs: Deque<U>) -> Bool {
    return !(lhs==rhs)
}