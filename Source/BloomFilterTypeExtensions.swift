//
//  BloomFilterTypeExtensions.swift
//  Buckets
//
//  Created by Mauricio Santos on 2016-02-03.
//  Copyright © 2016 Mauricio Santos. All rights reserved.
//

import Foundation

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

private func bytesFromStruct<T>(value: T) -> [UInt8] {
    var theValue = value
    return withUnsafePointer(&theValue) {
        Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(T)))
    }
}