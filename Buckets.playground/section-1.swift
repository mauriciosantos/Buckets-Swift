// Playground - noun: a place where people can play

import Foundation
import Buckets

var tr = Trie<String>()
tr.insertSequence("hola")
tr.hasPrefix("hoa")

var cop = tr

tr.insertSequence("holb")
cop.containsSequence("holb")
tr.containsSequence("holb")



var pr = PriorityQueue<Int>(<)
pr.enqueue(4)
pr.enqueue(2)
pr.first