//
//  BloomFilterTypeExtensions.swift
//  Buckets
//
//  Created by Mauricio Santos on 2016-02-03.
//  Copyright © 2016 Mauricio Santos. All rights reserved.
//

import Foundation

extension Bool: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension Double: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension Float: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension Int: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension Int8: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension Int16: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension Int32: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension Int64: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt8: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt16: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt32: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension UInt64: BloomFilterType {
    public var bytes: Data {return bytesFromStruct(self)}
}
extension String: BloomFilterType {
    public var bytes: Data {return self.data(using: .utf8)!}
}

private func bytesFromStruct<T>(_ value: T) -> Data {
    var data = Data()
    var input = value
    let buffer = UnsafeBufferPointer(start: &input, count: 1)
    data.append(buffer)
    return data
}
