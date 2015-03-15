//
//  Stack.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/19/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

public struct Stack<T> {

    public var count : Int {
        return elements.count
    }
    public var isEmpty: Bool {
        return elements.isEmpty
    }
    public var top: T? {
        return elements.last
    }
    
    private var elements = [T]()

    public init() {}
    
    public mutating func push(element: T) {
        elements.append(element)
    }
    
    public mutating func pop() -> T? {
        return !isEmpty ? elements.removeLast() : nil
    }
    
    public mutating func removeAll(keepCapacity keep: Bool = true)  {
        elements.removeAll(keepCapacity:keep)
    }
}

// MARK: - SequenceType

extension Stack: SequenceType {
    
    public func generate() -> GeneratorOf<T> {
        var index = count - 1
        return GeneratorOf<T> {
            if index >= 0 {
                let value = self.elements[index]
                index--
                return value
            }
            return nil
        }
    }
}

// MARK: - Operators

public func ==<U: Equatable>(lhs: Stack<U>, rhs: Stack<U>) -> Bool {
    return lhs.elements == rhs.elements
}

public func !=<U: Equatable>(lhs: Stack<U>, rhs: Stack<U>) -> Bool {
    return !(lhs == rhs)
}

// MARK: - ArrayLiteralConvertible

extension Stack: ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        for element in elements {
            push(element)
        }
    }
}