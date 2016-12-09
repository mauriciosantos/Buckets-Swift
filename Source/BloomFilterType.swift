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
    
    /// Returns a data representation of self.
    var bytes: Data {get}
}
