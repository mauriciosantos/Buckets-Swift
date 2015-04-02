// Playground - noun: a place where people can play

import Foundation
import Buckets




var mp: Multimap<Int,String> = [1:"2", 1:"2", 4:"34"]
mp[1]

var tr = Trie<String>()
tr.insertSequence("hello")
tr.hasPrefix("hello")

var cop = tr

tr.insertSequence("holb")
cop.containsSequence("holb")
tr.containsSequence("holb")

var str: String

