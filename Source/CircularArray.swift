//
//  CircularArray.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/21/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A circular array provides most of the features of a standard array
/// such as constant-time random access in addition to amortized constant-time
/// insertion/removal at both ends, instead of just one end.
/// It allows to get or set elements using subscript notation.
///
/// Conforms to `SequenceType`, `MutableCollectionType`,
/// `ArrayLiteralConvertible`, `Equatable`, `Printable`, `DebugPrintable` and `ReconstructableSequence`.
public struct CircularArray<T> {
    
    // MARK: Creating a Circular Array
    
    /// Constructs an empty circular array.
    public init() {}
    
    /// Constructs a circular array with a given number of elements, each 
    /// initialized to the same value.
    public init(count: Int, repeatedValue: T) {
        if count < 0 {
            fatalError("Can't construct CircularArray with count < 0")
        }
        var nextPowerOfTwo = 1
        while nextPowerOfTwo < count + 1 {
            nextPowerOfTwo *= 2
        }
        
        let capacity = max(nextPowerOfTwo, Constants.DefaultCapacity)
        items = [T?](count: capacity, repeatedValue: repeatedValue)
        items[count..<capacity] = [nil]
        tail = count
    }
    
    /// Constructs a circular array from a sequence, such as an array.
    public init<S: SequenceType where S.Generator.Element == T>(_ elements: S){
        for e in elements {
            append(e)
        }
    }
    
    // MARK: Querying a Circular Array
    
    /// Number of elements stored in the circular array.
    public var count : Int {
        return (tail - head) & (items.count - 1)
    }
    
    /// Returns `true` if and only if the circular array is empty.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// The first element, or `nil` if the circular array is empty.
    public var first: T? {
        return items[head]
    }
    
    /// The last element, or `nil` if the circular array is empty.
    public var last: T? {
        return items[decreaseIndex(tail)]
    }
    
    // MARK: Adding and Removing Elements
    
    /// Adds a new item as the first element in an existing circular array.
    public mutating func prepend(element: T) {
        head = decreaseIndex(head)
        items[head] = element
        checkCapacity()
    }
    
    /// Adds a new item as the last element in an existing circular array.
    public mutating func append(element: T) {
        items[tail] = element
        tail = increaseIndex(tail)
        checkCapacity()
    }
    
    /// Removes the first element from the circular array and returns it.
    ///
    /// - returns: The first element, or `nil` if the circular array is empty.
    public mutating func removeFirst() -> T? {
        if let value = first {
            items[head] = nil
            head = increaseIndex(head)
            return value
        }
        return nil
    }
    
    /// Inserts an element into the collection at a given index.
    /// Use this method to insert a new element anywhere within the range
    /// of existing items, or as the last item. The index must be less
    /// than or equal to the number of items in the circular array. If you
    /// attempt to remove an item at a greater index, you’ll trigger an error.
    public mutating func insert(element: T, atIndex index: Int) {
        checkIndex(index, lessThan: count + 1)
        append(element)
        for i in (count - 2).stride(through: index, by: -1) {
            let rIndex = realIndex(i)
            let nextIndex = realIndex(i+1)
            items[nextIndex] = items[rIndex]
        }
        items[index] = element
    }
    
    /// Removes the last element from the circular array and returns it.
    ///
    /// - returns: The last element, or nil if the circular array is empty.
    public mutating func removeLast() -> T? {
        if let value = last {
            tail = decreaseIndex(tail)
            items[tail] = nil
            return value
        }
        return nil
    }
    
    /// Removes the element at the given index and returns it. 
    ///
    /// The index must be less than the number of items in the 
    /// circular array. If you attempt to remove an item at a 
    /// greater index, you’ll trigger an error.
    public mutating func removeAtIndex(index: Int) -> T {
        checkIndex(index)
        let element = items[realIndex(index)]
        
        for i in (index + 1)..<count {
            let rIndex = realIndex(i)
            let prevIndex = realIndex(i-1)
            items[prevIndex] = items[rIndex]
        }
        removeLast()
        return element!
    }
    
    /// Removes all the elements from the collection, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true)  {
        if !keep {
            items.removeAll(keepCapacity: false)
        } else {
            items[0 ..< items.count] = [nil]
        }
        tail = 0
        head = 0
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Regular array holding the elements.
    private var items = [T?](count: Constants.DefaultCapacity, repeatedValue: nil)
    
    /// The real index of the first item.
    private var head: Int = 0
    
    /// The real index of the last item + 1.
    private var tail: Int = 0
    
    private func increaseIndex(index: Int) -> Int {
        return (index + 1) & (items.count - 1)
    }
    
    private func decreaseIndex(index: Int) -> Int {
        return (index - 1) & (items.count - 1)
    }
    
    private func realIndex(logicalIndex: Int) -> Int {
        return (head + logicalIndex) & (items.count - 1)
    }
    
    private mutating func checkCapacity() {
        if head != tail {
            return
        }
        
        // Array full. Create a bigger one
        
        var newArray = [T?](count: items.count * 2, repeatedValue: nil)
        let nFront = items.count - head
        newArray[0 ..< nFront] = items[head ..< items.count]
        newArray[nFront ..< nFront + head] = items[0 ..< head]

        head = 0
        tail = items.count
        items = newArray
    }
    
    private func checkIndex(index: Int, lessThan: Int? = nil) {
        let bound = lessThan == nil ? count : lessThan
        if index < 0 || index >= bound!  {
            fatalError("Index out of range (\(index))")
        }
    }
}

extension CircularArray: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality.
    ///
    /// - returns: A generator over the elements.
    public func generate() -> AnyGenerator<T> {
        return AnyGenerator(IndexingGenerator(self))
    }
}

extension CircularArray: MutableCollectionType {
    
    // MARK: MutableCollectionType Protocol Conformance
    
    /// Always zero, which is the index of the first element when non-empty.
    public var startIndex : Int {
        return 0
    }
    
    /// Always `count`, which is  the successor of the last valid subscript argument.
    public var endIndex : Int {
        return count
    }
    
    /// Provides random access to elements using square bracket notation.
    /// The index must be less than the number of items in the circular array.
    /// If you attempt to get or set an item at a greater 
    /// index, you’ll trigger an error.
    public subscript(index: Int) -> T {
        get {
            checkIndex(index)
            let rIndex = realIndex(index)
            return items[rIndex]!
        }
        set {
            checkIndex(index)
            let rIndex = realIndex(index)
            items[rIndex] = newValue
        }
    }
}

extension CircularArray: ArrayLiteralConvertible {
    
    // MARK: ArrayLiteralConvertible Protocol Conformance
    
    /// Constructs a circular array using an array literal.
    /// `let example: CircularArray<Int> = [1,2,3]`
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

extension CircularArray: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual 
    /// representation of the circular array.
    public var description: String {
        return "[" + self.map {"\($0)"}.joinWithSeparator(", ") + "]"
    }
}

//extension CircularArray: ReconstructableSequence {}

// MARK: - Constants

private struct Constants {
    // Must be power of 2
    private static let DefaultCapacity = 8
}

// MARK: - Operators

// MARK: CircularArray Operators

/// Returns `true` if and only if the circular arrays contain the same elements 
/// in the same logical order.
/// The underlying elements must conform to the `Equatable` protocol.
public func ==<T: Equatable>(lhs: CircularArray<T>, rhs: CircularArray<T>) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    return lhs.elementsEqual(rhs)
}

public func !=<T: Equatable>(lhs: CircularArray<T>, rhs: CircularArray<T>) -> Bool {
    return !(lhs==rhs)
}

