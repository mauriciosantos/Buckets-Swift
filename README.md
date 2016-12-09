# [Buckets](https://github.com/mauriciosantos/Buckets-Swift/)

[![Build Status](https://travis-ci.org/mauriciosantos/Buckets-Swift.svg?branch=master)](https://travis-ci.org/mauriciosantos/Buckets-Swift)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Buckets.svg)](https://img.shields.io/cocoapods/v/Buckets.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Buckets.svg?style=flat)](http://cocoadocs.org/docsets/Buckets)

**Swift Collections Library**

Buckets is a complete, tested and documented collections library for swift.

## Requirements

Swift 3.0+ platforms such as:

Linux/iOS 9.0+/MacOS 10.10+/watchOS 2.0+/tvOS 9.0+

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

## Setup

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C projects. The latest version adds support for embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Buckets into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

pod 'Buckets', '~> 2.0'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage#-carthage) is a decentralized dependency manager that automates the process of adding frameworks to your application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Buckets into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "mauriciosantos/Buckets-Swift" ~> 2.0
```

### Swift Package Manager

See [Swift Package Manager documentation](https://swift.org/package-manager/#conceptual-overview)

### Manually

You can also integrate Buckets into your Xcode project manually:

- Download the [latest release](https://github.com/mauriciosantos/Buckets-Swift/releases) and unzip it in your project's folder.
- Open the `Buckets` folder, and drag `Buckets.xcodeproj` into the file navigator of your app project. This means inside your project, not at the top level.
- Ensure that the deployment target of Buckets.framework matches that of the application target.
- Open your project's "Build Phases" panel. Expand the "Target Dependencies" group, and add `Buckets.framework`.
- Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Set the "Destination" to "Frameworks", and add `Buckets.framework`. There are 4 versions for each platform. Select the right one.

## Usage

All collection types are implemented as structures. This means they are copied when they are assigned to a new constant or variable, or when they are passed to a function or method.

You shouldn't worry about copying structs:  

> The behavior you see in your code will always be as if a copy took place. However, Swift only performs an actual copy behind the scenes when it is absolutely necessary to do so. Swift manages all value copying to ensure optimal performance, and you should not avoid assignment to try to preempt this optimization.

Buckets collection types are optimized in the same way.

### Walkthrough

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

var pQueue = PriorityQueue<Int>(sortedBy: <)
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

var sss = String("hola");

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

Read the [documentation](http://mauriciosantos.github.io/Buckets-Swift/Data%20Structures.html).

## Contact

Mauricio Santos, [mauriciosantoss@gmail.com](mailto:mauriciosantoss@gmail.com)
