//
//  Queue.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/19/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

public struct Queue<T> {
    
    private var items = CircularArray<T>()
    
    public var isEmpty: Bool {
        return count == 0
    }
    public var first: T? {
        return items.first
    }
    public var count : Int {
        return items.count
    }
    public init() {}
    
    public mutating func enqueue(element: T) {
        items.append(element)
    }
    
    public mutating func dequeue() -> T? {
        return items.removeFirst()
    }
    
    public mutating func removeAll(keepCapacity keep: Bool = true)  {
        items.removeAll(keepCapacity: keep)
    }
}

// MARK: - SequenceType

extension Queue: SequenceType {
    
    public func generate() -> GeneratorOf<T> {
        return items.generate()
    }
}

// MARK: - ArrayLiteralConvertible

extension Queue: ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        for element in elements {
            enqueue(element)
        }
    }
}

// MARK: - Operators

public func ==<U: Equatable>(lhs: Queue<U>, rhs: Queue<U>) -> Bool {
    return lhs.items == rhs.items
}

public func !=<U: Equatable>(lhs: Queue<U>, rhs: Queue<U>) -> Bool {
    return !(lhs==rhs)
}


