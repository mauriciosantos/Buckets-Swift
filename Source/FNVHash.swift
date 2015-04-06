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
func fnv1<S:SequenceType where S.Generator.Element == UInt8>(bytes: S) -> UInt {
    var hash = Constants.OffsetBasis
    for byte in bytes {
        hash = hash &* Constants.FNVPrime // &* means multiply with overflow
        hash ^= UInt(byte)
    }
    return hash
}

/// Calculates FNV-1a hash from a raw byte sequence, such as an array.
func fnv1a<S:SequenceType where S.Generator.Element == UInt8>(bytes: S) -> UInt {
    var hash = Constants.OffsetBasis
    for byte in bytes {
        hash ^= UInt(byte)
        hash = hash &* Constants.FNVPrime
    }
    return hash
}

/// Calculates FNV-1 hash from a String using it's UTF8 representation.
func fnv1(str: String) -> UInt {
    return fnv1(str.utf8)
}

/// Calculates FNV-1a hash from a String using it's UTF8 representation.
func fnv1a(str: String) -> UInt {
    return fnv1a(str.utf8)
}

/// Calculates FNV-1 hash from a numeric type.
func fnv1<T: NumericType>(value: T) -> UInt {
    return fnv1(bytesFromNumber(value))
}

private func bytesFromNumber<T>(var value: T) -> [UInt8] {
    return withUnsafePointer(&value) {
        Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(T)))
    }
}


protocol NumericType {}
extension Double : NumericType {}
extension Float  : NumericType {}
extension Int    : NumericType {}
extension Int8   : NumericType {}
extension Int16  : NumericType {}
extension Int32  : NumericType {}
extension Int64  : NumericType {}
extension UInt   : NumericType {}
extension UInt8  : NumericType {}
extension UInt16 : NumericType {}
extension UInt32 : NumericType {}
extension UInt64 : NumericType {}