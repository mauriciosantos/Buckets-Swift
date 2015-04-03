//
//  Bimap.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/2/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

public struct BidirectionalMap<Key: Hashable, Value: Hashable> {
    
    private var keysToValues = [Key: Value]()
    private var valuesToKeys = [Value: Key]()
    
    public init() {}
    
    public subscript(#key: Key) -> Value? {
        get {
            return keysToValues[key]
        }
        set {
            if newValue == nil {
                if let oldValue = keysToValues[key] {
                    valuesToKeys.removeValueForKey(oldValue)
                }
            }
            keysToValues[key] = newValue
            if let newValue = newValue {
                valuesToKeys[newValue] = key
            }
        }
    }
    
    public subscript(#value: Value) -> Key? {
        get {
            return valuesToKeys[value]
        }
        set(newKey) {
            if newKey == nil {
                if let oldKey = valuesToKeys[value] {
                    keysToValues.removeValueForKey(oldKey)
                }
            }
            valuesToKeys[value] = newKey
            if let newKey = newKey {
                keysToValues[newKey] = value
            }
        }
    }
}