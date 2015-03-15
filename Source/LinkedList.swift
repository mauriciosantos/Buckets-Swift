////
////  LinkedList.swift
////  Buckets
////
////  Created by Mauricio Santos on 1/4/15.
////
////
//
//import Foundation
//
//// MARK: LinkedListNode
//
//private class LinkedListNode<T> {
//    var value : T
//    var next : LinkedListNode<T>?
//    
//    init(value: T) {
//        self.value = value
//    }
//}
//
//// MARK: LinkedList Base
//
//public class LinkedList<T>: ArrayLiteralConvertible  {
//    
//    public var first : T? {return head?.value}
//    public var last : T? {return tail?.value}
//    public var isEmpty : Bool {return count==0}
//    public private(set) var count = 0
//    
//    private var head : LinkedListNode<T>?
//    private var tail : LinkedListNode<T>?
//    
//    
//    public convenience required init(arrayLiteral elements: T...) {
//        self.init()
//        for element in elements {
//            append(element)
//        }
//    }
//    
//    public convenience init(other: LinkedList<T>) {
//        self.init()
//        var otherNode = other.head
//        while let value = otherNode?.value {
//            append(value)
//            otherNode = otherNode?.next
//        }
//    }
//    
//    public func append(element: T) {
//        // TODO: in swift 1.2 isUniquelyReferencedNonObjC
//        let newNode = LinkedListNode<T>(value: element)
//        if let tail = tail {
//            tail.next = newNode
//        } else {
//            head = newNode
//        }
//        tail = newNode
//        count++
//    }
//    
//    public func preppend(element: T) {
//        let newNode = LinkedListNode<T>(value: element)
//        newNode.next = head
//        head = newNode
//        if tail == nil {
//            tail = head
//        }
//        count++
//    }
//    
//    public func removeAll() {
//        head = nil
//        tail = nil
//        count = 0
//    }
//    
//    public func removeFirst() -> T? {
//        var removed = head?.value
//        if head === tail {
//            tail = nil
//        }
//        head = head?.next
//        if  removed != nil {
//            count--
//        }
//        return removed
//    }
//}
//
////MARK: Operators
//
//
//
//public func ==<U: Equatable>(lhs: LinkedList<U>, rhs: LinkedList<U>) -> Bool {
//
//    if lhs.count != rhs.count {
//        return false
//    }
//
//    var lHead = lhs.head
//    var rHead = rhs.head
//
//    while lHead != nil {
//        if lHead?.value != rHead?.value {
//            return false
//        } else {
//            lHead = lHead?.next
//            rHead = rHead?.next
//        }
//    }
//    return true
//}
//
//public func !=<U: Equatable>(lhs: LinkedList<U>, rhs: LinkedList<U>) -> Bool {
//    return !(lhs==rhs)
//}
//
//// MARK: SequenceType
//
//extension LinkedList: SequenceType {
//
//    public func generate() -> GeneratorOf<T> {
//
//        var optionalNext = head
//
//        // Construct a GeneratorOf<T> instance,
//        // passing a closure that returns the next
//        // value in the iteration
//        return GeneratorOf<T> {
//            if let next = optionalNext {
//                let value = next.value
//                optionalNext = next.next
//                return value
//            } else {
//                return nil
//            }
//        }
//    }
//}
//
//// MARK: Printable
//
//extension LinkedList: Printable {
//
//    public var description: String {
//        var result = "["
//        var first = true
//        for element in self {
//            if !first {
//                result += "->"
//            }
//            result += "\(element)"
//            first = false
//        }
//        result  += "]"
//        return result
//    }
//}
//
//// MARK: Functional Programming
//
//extension LinkedList  {
//
//    public func filter(includeElement: (T) -> Bool) -> LinkedList<T> {
//        var newList = LinkedList<T>()
//        for element in self {
//            if includeElement(element) {
//                newList.append(element)
//            }
//        }
//        return newList
//    }
//
//    public func map<U>(transform: (T) -> U) -> LinkedList<U> {
//        var newList = LinkedList<U>()
//        for element in self {
//            newList.append(transform(element))
//        }
//        return newList
//    }
//
//    public func reduce<U>(initial: U, combine: (U, T) -> U) -> U {
//        var result = initial
//        for element in self {
//            result = combine(result, element)
//        }
//        return result
//    }
//}
//
//extension LinkedList  {
//
//    public func contains<U : Equatable>(element: U) -> Bool {
//        for item in self {
//            if let item = (item as? U) {
//                if item == element {
//                    return true
//                }
//            }
//        }
//        return false
//    }
//}
//
//public func contains<U: Equatable>(list: LinkedList<U>, element: U) -> Bool {
//    for e in list {
//        if e == element {
//            return true
//        }
//    }
//    return false
//}
