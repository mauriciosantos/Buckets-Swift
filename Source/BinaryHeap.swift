//
//  BinaryHeap.swift
//  Buckets
//
//  Created by Mauricio Santos on 2/21/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

// Max Heap
struct BinaryHeap<T> : SequenceType {
    
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
    private let isOrderedBefore: (T,T) -> Bool
    private var items = [T]()
    
    init(compareFunction: (T,T) -> Bool) {
        isOrderedBefore = compareFunction
    }
    
    mutating func insert(element: T) {
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
    
    mutating func removeAll(keepCapacity keep: Bool = true)  {
        items.removeAll(keepCapacity: keep)
    }
    
    func generate() -> GeneratorOf<T> {
        return GeneratorOf(items.generate())
    }
    
    private mutating func siftUp() {
        var i = count - 1
        var paren = parent(i)
        while i > 0 && !isOrderedBefore(items[paren], items[i]) {
            swap(&items[i], &items[paren])
            i = paren
            paren = parent(i)
        }
    }
    
    private mutating func siftDown() {
        // Returns the index of the maximum element if it exists, otherwise -1
        func maxIndex(i: Int, j: Int) -> Int {
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
        
        var i = 0
        var max = maxIndex(leftChild(i), rightChild(i))
        while max >= 0 && !isOrderedBefore(items[i], items[max]) {
            swap(&items[max], &items[i])
            i = max
            max = maxIndex(leftChild(i), rightChild(i))
        }
    }
    
    private func parent(index: Int) -> Int {
        return (index - 1) / 2
    }
    
    private func leftChild(index: Int) -> Int {
        return (2 * index) + 1
    }
    
    private func rightChild(index: Int) -> Int {
        return (2 * index) + 2
    }
}

