# [Buckets](https://github.com/mauriciosantos/Buckets-Swift/)
**Swift Collection Data Structures Library**

Buckets is a complete, tested and documented collections library for swift.

## Requirements

- iOS 8.0+ or OS X 10.9+
- Xcode 6.3+

## Included collections

- [Queue](http://mauriciosantos.github.io/Buckets-Swift/Structs/Queue.html)
- [Deque](http://mauriciosantos.github.io/Buckets-Swift/Structs/Deque.html)
- [Stack](http://mauriciosantos.github.io/Buckets-Swift/Structs/Stack.html)
- [PriorityQueue](http://mauriciosantos.github.io/Buckets-Swift/Structs/PriorityQueue.html)
- [Multiset](http://mauriciosantos.github.io/Buckets-Swift/Structs/Multiset.html)
- [Multimap](http://mauriciosantos.github.io/Buckets-Swift/Structs/Multimap.html)
- [Bimap](http://mauriciosantos.github.io/Buckets-Swift/Structs/Bimap.html)
- [Graph](http://mauriciosantos.github.io/Buckets-Swift/Structs/Graph.html)
- [Trie](http://mauriciosantos.github.io/Buckets-Swift/Structs/Trie.html)
- [Matrix](http://mauriciosantos.github.io/Buckets-Swift/Structs/Matrix.html)
- [BitArray](http://mauriciosantos.github.io/Buckets-Swift/Structs/BitArray.html)
- [CircularArray](http://mauriciosantos.github.io/Buckets-Swift/Structs/CircularArray.html)
- [BloomFilter](http://mauriciosantos.github.io/Buckets-Swift/Structs/BloomFilter.html)

## Usage

All collection types are implemented as structures. This means they are copied when they are assigned to a new constant or variable, or when they are passed to a function or method. 

You shouldn't worry about copying structs:  

> The behavior you see in your code will always be as if a copy took place. However, Swift only performs an actual copy behind the scenes when it is absolutely necessary to do so. Swift manages all value copying to ensure optimal performance, and you should not avoid assignment to try to preempt this optimization.

Buckets collection types are optimized in the same way.

### Simple tutorial

```swift
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
```

Read the [documentation](http://mauriciosantos.github.io/Buckets-Swift/Structs.html).

## Contact

Mauricio Santos, [mauriciosantoss@gmail.com](mailto:mauriciosantoss@gmail.com)
