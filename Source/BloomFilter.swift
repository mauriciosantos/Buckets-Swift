//
//  BloomFilter.swift
//  Buckets
//
//  Created by Mauricio Santos on 3/8/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

private struct Constants {
    static let DefaultFPP = 0.03
}

// Printable Description must be unique.
public struct BloomFilter<T: Printable> {
    
    public let falsePositiveProbability: Double
    
    public var approximateCount: Int {
        let count = Double(bits.count)
        let bitsSetToOne = Double(bits.cardinality)
        let hashFunctions = Double(numberOfHashFunctions)
        
        let result = -count*log(1.0 - bitsSetToOne/count)/hashFunctions
        if !result.isFinite {
            return Int.max
        }
        return Int(min(result, Double(Int.max)))
    }
    
    private var bits: BitArray
    
    /// Optimal number of hash functions
    private let numberOfHashFunctions: Int
    
    /**
    Creates a bloom filter
    
    :param: expectedSize Expected number of insertions.
    :param: falsePositiveProbability double < 1 and > 0
    
    :returns:
    */
    public init(expectedSize: Int, falsePositiveProbability fpp: Double = Constants.DefaultFPP) {
        
        if expectedSize < 0 {
            fatalError("Can't construct BloomFilter with expectedSize < 0")
        }
        
        if fpp <= 0.0 || fpp >= 1.0  {
            fatalError("Can't construct BloomFilter with false positive probability >= 1 or <= 0")
        }
        
        // See: http://en.wikipedia.org/wiki/Bloom_filter for calculations
        
        let n = Double(expectedSize)
        let m = n*log(1/fpp) / pow(log(2), 2)
        
        let bitArraySize = Int(m)
        bits = BitArray(count: bitArraySize, repeatedValue: false)
        
        let k = (m/n) * log(2)
        numberOfHashFunctions = Int(ceil(k))
        
        falsePositiveProbability = fpp
    }
    
    public mutating func insert(element: T) {
        for i in 0..<numberOfHashFunctions {
            let hashFunction = hashFunctionWithIndex(i)
            let index = hashFunction(element)
            bits[index] = true
        }
    }
    
    /// Returns true if the element might be in this bloom filter or false if it's definitely not.
    public func contains(element: T) -> Bool {
        for i in 0..<numberOfHashFunctions {
            let hashFunction = hashFunctionWithIndex(i)
            let index = hashFunction(element)
            if !bits[index] {
                return false
            }
        }
        return true
    }
    
    /// Creates any number of hash functions on the fly using just 2 predifined ones.
    /// See http://en.wikipedia.org/wiki/Double_hashing
    private func hashFunctionWithIndex(index: Int) -> (T) -> Int {
        var i = UInt(index)
        
        // Hi(x) = H0(x) + i*H1(x) mod table.size
        
        return  {
            let str = $0.description
            
            let result = fnv1a(str)
            
            
            return Int((fnv1(str) &+ i&*fnv1a(str)) % UInt(self.bits.count))
        }
    }
}