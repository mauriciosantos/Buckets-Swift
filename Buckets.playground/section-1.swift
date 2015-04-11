// Playground - noun: a place where people can play

import Foundation
import Buckets
import Accelerate


var v = [1.1, 2.0]
var s = 3.0
var vsresult = [Double](count : v.count, repeatedValue : 0.0)
vDSP_vsaddD(v, 1, &s, &vsresult, 1, vDSP_Length(v.count))
vsresult



var a = BloomFilter<String>(expectedCount: 2000)
