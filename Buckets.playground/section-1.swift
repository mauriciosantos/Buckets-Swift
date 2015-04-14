// Playground - noun: a place where people can play

import Foundation
import Buckets

var queue = Queue<String>()
queue.enqueue("first")
queue.enqueue("last")
queue.dequeue() // "first"

var deque = Deque<String>()
deque.enqueueLast("last")
deque.enqueueFirst("first")
deque.dequeueFirst() // "first"

var stack = Stack<String>()
stack.push("first")
stack.push("last")
stack.pop() // "last"

var pQueue = PriorityQueue<Int>(<)
pQueue.enqueue(3)
pQueue.enqueue(1)
pQueue.enqueue(2)
pQueue.dequeue() // 1

var multiset = Multiset<String>()
multiset.insert("a")
multiset.insert("b")
multiset.insert("a")
multiset.distinctCount // 2
multiset.count("a") // 2

var multimap = Multimap<String, Int>()
multimap.insertValue(1, forKey: "a")
multimap.insertValue(5, forKey: "a")
multimap["a"] // [1, 5]

var bimap = Bimap<String, Int>()
bimap[key: "a"] = 1
bimap[value: 3] = "b"
bimap[value: 1] // "a"
bimap[key: "b"] // 3

var graph = Graph<String, Int>()
graph["Boston", "NY"] = 5
graph["NY", "Miami"] = 5
graph.pathFrom("Boston", to: "Miami") // ["Boston", "NY", "Miami"]

var trie = Trie<String>()
trie.insert("Apple")
trie.insert("App Store")
trie.findPrefix("App") // ["App Store", "Apple"]

var matrix: Matrix<Double> = [[1,2,3], [4,5,6]]
matrix[1, 0] = 5
matrix - [[1,0,1], [1,0,1]] // [[0,2,2],[4,5,5]]

var bitArray: BitArray = [true, false]
bitArray.append(true)
bitArray.cardinality // 2

var circArray = CircularArray<Int>()
circArray.append(1)
circArray.prepend(2)
circArray.first // 2

var bFilter = BloomFilter<String>(expectedCount: 100)
bFilter.insert("a")
bFilter.contains("a") // true
