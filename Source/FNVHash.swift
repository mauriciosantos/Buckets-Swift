//
//  FNVHash.swift
//
//  A Swift implementation of the Fowler–Noll–Vo (FNV) hash function
//  See http://www.isthe.com/chongo/tech/comp/fnv/
//
//  Created by Mauricio Santos on 3/9/15.

import Foundation

// MARK:- Constants

private struct Constants {
    
    // FNV parameters
    
    #if arch(arm64) || arch(x86_64) // 64-bit
    
    static let OffsetBasis: UInt = 14695981039346656037
    static let FNVPrime: UInt = 1099511628211
    
    #else // 32-bit
    
    static let OffsetBasis: UInt = 2166136261
    static let FNVPrime: UInt = 16777619
    
    #endif
}

// MARK:- Public API

/// Calculates FNV-1 hash from a raw byte sequence, such as an array.
func fnv1<S:Sequence>(_ bytes: S) -> UInt where S.Iterator.Element == UInt8 {
    var hash = Constants.OffsetBasis
    for byte in bytes {
        hash = hash &* Constants.FNVPrime // &* means multiply with overflow
        hash ^= UInt(byte)
    }
    return hash
}

/// Calculates FNV-1a hash from a raw byte sequence, such as an array.
func fnv1a<S:Sequence>(_ bytes: S) -> UInt where S.Iterator.Element == UInt8 {
    var hash = Constants.OffsetBasis
    for byte in bytes {
        hash ^= UInt(byte)
        hash = hash &* Constants.FNVPrime
    }
    return hash
}
