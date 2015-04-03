// Playground - noun: a place where people can play

import Foundation
import Buckets


//var bimap = BiMap<String, String>()
//
//bimap[key: "hey"] = "hello"
////bimap[key: "hey"] = nil
//bimap[value: "hello"]



var mp: Multimap<Int,String> = [1:"2", 1:"2", 4:"34"]
mp[1]
mp[1, .Insert] = ["444"]
mp[1]
mp.insertValue(1, forKey: 2)



var multiset = Multiset<Int>([1,1,3])

multiset.description

var tr = Trie<String>()
tr.insertSequence("hello")
tr.hasPrefix("hello")

var cop = tr

tr.insertSequence("holb")
cop.containsSequence("holb")
tr.containsSequence("holb")

var str: String

