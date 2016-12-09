//
//  BinaryHeap.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/21/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

// Max Heap
struct BinaryHeap<T> : Sequence {
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    var count: Int {
        return items.count
    }
    var max: T? {
        return items.first
    }
    
    // returns true if the first argument has the highest priority
    fileprivate let isOrderedBefore: (T,T) -> Bool
    fileprivate var items = [T]()
    
    init(compareFunction: @escaping (T,T) -> Bool) {
        isOrderedBefore = compareFunction
    }
    
    mutating func insert(_ element: T) {
        items.append(element)
        siftUp()
    }
    
    mutating func removeMax() -> T? {
        if !isEmpty {
            let value = items[0]
            items[0] = items[count - 1]
            items.removeLast()
            if !isEmpty {
                siftDown()
            }
            return value
        }
        return nil
    }
    
    mutating func removeAll(keepingCapacity keep: Bool = false)  {
        items.removeAll(keepingCapacity: keep)
    }
    
    func makeIterator() -> AnyIterator<T> {
        return AnyIterator(items.makeIterator())
    }
    
    fileprivate mutating func siftUp() {
        func parent(_ index: Int) -> Int {
            return (index - 1) / 2
        }
        
        var i = count - 1
        var parentIndex = parent(i)
        while i > 0 && !isOrderedBefore(items[parentIndex], items[i]) {
            swap(&items[i], &items[parentIndex])
            i = parentIndex
            parentIndex = parent(i)
        }
    }
    
    fileprivate mutating func siftDown() {
        // Returns the index of the maximum element if it exists, otherwise -1
        func maxIndex(_ i: Int, _ j: Int) -> Int {
            if j >= count && i >= count {
                return -1
            } else if j >= count && i < count {
                return i
            } else if isOrderedBefore(items[i], items[j]) {
                return i
            } else {
                return j
            }
        }
        
        func leftChild(_ index: Int) -> Int {
            return (2 * index) + 1
        }
        
        func rightChild(_ index: Int) -> Int {
            return (2 * index) + 2
        }
        
        var i = 0
        var max = maxIndex(leftChild(i), rightChild(i))
        while max >= 0 && !isOrderedBefore(items[i], items[max]) {
            swap(&items[max], &items[i])
            i = max
            max = maxIndex(leftChild(i), rightChild(i))
        }
    }
}

// MARK: Heap Operators

/// Returns `true` if and only if the heaps contain the same elements
/// in the same order.
/// The underlying elements must conform to the `Equatable` protocol.
func ==<U: Equatable>(lhs: BinaryHeap<U>, rhs: BinaryHeap<U>) -> Bool {
    return lhs.items.sorted(by: lhs.isOrderedBefore) == rhs.items.sorted(by: rhs.isOrderedBefore)
}

func !=<U: Equatable>(lhs: BinaryHeap<U>, rhs: BinaryHeap<U>) -> Bool {
    return !(lhs==rhs)
}

