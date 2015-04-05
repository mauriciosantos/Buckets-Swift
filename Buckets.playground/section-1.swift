// Playground - noun: a place where people can play

import Foundation
import Buckets


//var bimap = BiMap<String, String>()
//
//bimap[key: "hey"] = "hello"
////bimap[key: "hey"] = nil
//bimap[value: "hello"]

var tr = Trie<String>()
tr.insert("hello")
tr.insert("hello")


tr.insert("holb")
tr.containsPrefix("rello")
tr.insert("holb")
tr.insert("holba")
tr.insert("holb")
tr.contains("")
tr.elements
tr.elementsMatchingPrefix("hol")
tr.longestPrefixMatching("holbaa")



