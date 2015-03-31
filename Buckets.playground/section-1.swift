// Playground - noun: a place where people can play

import Foundation
import Buckets

var tr = Trie<String>()
tr.insertSequence("hello")
tr.hasPrefix("helo")

var cop = tr

tr.insertSequence("holb")
cop.containsSequence("holb")
tr.containsSequence("holb")

var str: String

