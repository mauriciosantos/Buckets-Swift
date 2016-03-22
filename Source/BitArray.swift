//
//  BitArray.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/23/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// An array of boolean values stored
/// using individual bits, thus providing a
/// very small memory footprint. It has most of the features of a
/// standard array such as constant time random access and
/// amortized constant time insertion at the end of the array.
///
/// Conforms to `SequenceType`, `MutableCollectionType`,
/// `ArrayLiteralConvertible`, `Equatable`, `Hashable`, `Printable`, `DebugPrintable` and `ReconstructableSequence`.
public struct BitArray {
    
    // MARK: Creating a BitArray
    
    /// Constructs an empty bit array.
    public init() {}
    
    /// Constructs a bit array from a `Bool` sequence, such as an array.
    public init<S: SequenceType where S.Generator.Element == Bool>(_ elements: S){
        for value in elements {
            append(value)
        }
    }
    
    /// Constructs a new bit array from an `Int` array representation.
    /// All values different than 0 are considered `true`.
    public init(intRepresentation : [Int]) {
        bits.reserveCapacity((intRepresentation.count/Constants.IntSize) + 1)
        for value in intRepresentation {
            append(value != 0)
        }
    }
    
    /// Constructs a new bit array with `count` bits set to the specified value.
    public init(count:Int, repeatedValue: Bool) {
        if count < 0 {
            fatalError("Can't construct BitArray with count < 0")
        }
        
        let numberOfInts = (count/Constants.IntSize) + 1
        let intValue = repeatedValue ? ~0 : 0
        bits = [Int](count: numberOfInts, repeatedValue: intValue)
        self.count = count
        
        if repeatedValue {
            bits[bits.count - 1] = 0
            let missingBits = count % Constants.IntSize
            self.count = count - missingBits
            for _ in 0..<missingBits {
                append(repeatedValue)
            }
            cardinality = count
        }
    }
    
    // MARK: Querying a BitArray
    
    /// Number of bits stored in the bit array.
    public private(set) var count = 0
    
    /// Returns `true` if and only if `count == 0`.
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// The first bit, or nil if the bit array is empty.
    public var first: Bool? {
        return isEmpty ? nil : valueAtIndex(0)
    }
    
    /// The last bit, or nil if the bit array is empty.
    public var last: Bool? {
        return isEmpty ? nil : valueAtIndex(count-1)
    }
    
    /// The number of bits set to `true` in the bit array.
    public private(set) var cardinality = 0
    
    
    // MARK: Adding and Removing Bits
    
    /// Adds a new `Bool` as the last bit.
    public mutating func append(bit: Bool) {
        if realIndexPath(count).arrayIndex >= bits.count {
            bits.append(0)
        }
        setValue(bit, atIndex: count)
        count += 1
    }
    
    /// Inserts a bit into the array at a given index.
    /// Use this method to insert a new bit anywhere within the range
    /// of existing bits, or as the last bit. The index must be less
    /// than or equal to the number of bits in the bit array. If you
    /// attempt to remove a bit at a greater index, you’ll trigger an error.
    public mutating func insert(bit: Bool, atIndex index: Int) {
        checkIndex(index, lessThan: count + 1)
        append(bit)
        for i in (count - 2).stride(through: index, by: -1) {
            let iBit = valueAtIndex(i)
            setValue(iBit, atIndex: i+1)
        }
        setValue(bit, atIndex: index)
    }
    
    /// Removes the last bit from the bit array and returns it.
    ///
    /// - returns: The last bit, or nil if the bit array is empty.
    public mutating func removeLast() -> Bool? {
        if let value = last {
            setValue(false, atIndex: count-1)
            count -= 1
            return value
        }
        return nil
    }
    
    /// Removes the bit at the given index and returns it.
    /// The index must be less than the number of bits in the
    /// bit array. If you attempt to remove a bit at a
    /// greater index, you’ll trigger an error.
    public mutating func removeAtIndex(index: Int) -> Bool {
        checkIndex(index)
        let bit = valueAtIndex(index)
        
        for i in (index + 1)..<count {
            let iBit = valueAtIndex(i)
            setValue(iBit, atIndex: i-1)
        }
        
        removeLast()
        return bit
    }
    
    /// Removes all the bits from the array, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepCapacity keep: Bool = true)  {
        if !keep {
            bits.removeAll(keepCapacity: false)
        } else {
            bits[0 ..< bits.count] = [0]
        }
        count = 0
        cardinality = 0
    }
    
    // MARK: Private Properties and Helper Methods
    
    /// Structure holding the bits.
    private var bits = [Int]()
    
    private func valueAtIndex(logicalIndex: Int) -> Bool {
        let indexPath = realIndexPath(logicalIndex)
        var mask = 1 << indexPath.bitIndex
        mask = mask & bits[indexPath.arrayIndex]
        return mask != 0
    }
    
    private mutating func setValue(newValue: Bool, atIndex logicalIndex: Int) {
        
        let indexPath = realIndexPath(logicalIndex)
        let mask = 1 << indexPath.bitIndex
        let oldValue = mask & bits[indexPath.arrayIndex] != 0
        
        switch (oldValue, newValue) {
            case (false, true):
                cardinality += 1
            case (true, false):
                cardinality -= 1
            default:
                break
        }
        
        if newValue {
            bits[indexPath.arrayIndex] |= mask
        } else {
            bits[indexPath.arrayIndex] &= ~mask
        }
    }
    
    private func realIndexPath(logicalIndex: Int) -> (arrayIndex: Int, bitIndex: Int) {
        return (logicalIndex / Constants.IntSize, logicalIndex % Constants.IntSize)
    }
    
    private func checkIndex(index: Int, lessThan: Int? = nil) {
        let bound = lessThan == nil ? count : lessThan
        if index < 0 || index >= bound!  {
            fatalError("Index out of range (\(index))")
        }
    }
    
    // MARK: Constants
    
    private struct Constants {
        // Int size in bits
        static let IntSize = sizeof(Int) * 8
    }
}

// MARK: -

extension BitArray: SequenceType {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality.
    ///
    /// - returns: A generator over the bits.
    public func generate() -> AnyGenerator<Bool> {
        return AnyGenerator(IndexingGenerator(self))
    }
}

extension BitArray: MutableCollectionType {
    
    // MARK: MutableCollectionType Protocol Conformance
    
    /// Always zero, which is the index of the first bit when non-empty.
    public var startIndex : Int {
        return 0
    }
    
    /// Always `count`, which the successor of the last valid
    /// subscript argument.
    public var endIndex : Int {
        return count
    }
    
    /// Provides random access to individual bits using square bracket noation.
    /// The index must be less than the number of items in the bit array.
    /// If you attempt to get or set a bit at a greater
    /// index, you’ll trigger an error.
    public subscript(index: Int) -> Bool {
        get {
            checkIndex(index)
            return valueAtIndex(index)
        }
        set {
            checkIndex(index)
            setValue(newValue, atIndex: index)
        }
    }
}

extension BitArray: ArrayLiteralConvertible {
    
    // MARK: ArrayLiteralConvertible Protocol Conformance
    
    /// Constructs a bit array using a `Bool` array literal.
    /// `let example: BitArray = [true, false, true]`
    public init(arrayLiteral elements: Bool...) {
        bits.reserveCapacity((elements.count/Constants.IntSize) + 1)
        for element in elements {
            append(element)
        }
    }
}

extension BitArray: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the bit array.
    public var description: String {
        return "[" + self.map {"\($0)"}.joinWithSeparator(", ") + "]"
    }
}

extension BitArray: Equatable {
}


// MARK: BitArray Equatable Protocol Conformance

/// Returns `true` if and only if the bit arrays contain the same bits in the same order.
public func ==(lhs: BitArray, rhs: BitArray) -> Bool {
    if lhs.count != rhs.count || lhs.cardinality != rhs.cardinality {
        return false
    }
    return lhs.elementsEqual(rhs)
}

extension BitArray: Hashable {
    // MARK: Hashable Protocol Conformance
    
    /// The hash value.
    /// `x == y` implies `x.hashValue == y.hashValue`
    public var hashValue: Int {
        var result = 43
        result = (31 ^ result) ^ count
        for element in self {
            result = (31 ^ result) ^ element.hashValue
        }
        return result
    }
}
