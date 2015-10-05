//
//  BloomFilterType.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/10/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// Specifies an element type supported by BloomFilter.
///
/// The easiest way to implement this protocol is by
/// joining the byte arrays from properties of already conforming types, such as strings or numbers.
public protocol BloomFilterType {
    
    /// Returns a byte array representation of self.
    var bytes: [UInt8] {get}
}

extension Bool: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension Double: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension Float: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension Int: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension Int8: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension Int16: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension Int32: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension Int64: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension UInt: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension UInt8: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension UInt16: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension UInt32: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension UInt64: BloomFilterType {
    public var bytes: [UInt8] {return bytesFromStruct(self)}
}
extension String: BloomFilterType {
    public var bytes: [UInt8] {return [UInt8](self.utf8)}
}

private func bytesFromStruct<T>(var value: T) -> [UInt8] {
    return withUnsafePointer(&value) {
        Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(T)))
    }
}