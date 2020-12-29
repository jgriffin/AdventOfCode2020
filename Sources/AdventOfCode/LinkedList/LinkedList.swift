//
//  Node.swift
//
//
//  Created by Griff on 12/28/20.
//

import Foundation

public class LinkedList<Value>: List, Sequence {
    public typealias NodeT = ListNode<Value>
    public typealias Element = NodeT

    internal var head: NodeT?
    internal var tail: NodeT?

    public required init(head: NodeT?) {
        self.head = head
        tail = head?.last
    }

    public var isEmpty: Bool { head == nil }
    public var first: NodeT? { head }
    public var last: NodeT? { tail }

    public func makeIterator() -> ListIterator<LinkedList<Value>> {
        ListIterator<LinkedList<Value>>(list: self, current: head)
    }

    public var asArray: [Value] { map(\.value) }
}

public extension LinkedList {
    convenience init(values: [Value]) {
        self.init(head: nil)
        insert(values)
    }

    static var empty: LinkedList {
        .init(head: nil)
    }
}

public extension LinkedList {
    func findNode(where passing: (Value) -> Bool) -> NodeT? {
        var node = head

        repeat {
            if let value = node?.value,
               passing(value)
            {
                return node
            }
            node = node?.next
        } while node != nil

        return nil
    }

    func findNodeBefore(node: NodeT) -> NodeT? where Value: Comparable {
        guard head !== node else {
            // the head has no nodeBefore
            return nil
        }

        var nodeBefore = head
        while let next = nodeBefore?.next {
            if next == node {
                return nodeBefore
            }
            nodeBefore = next
        }

        return nil
    }
}

public extension LinkedList {
    func push(_ v: Value) {
        head = NodeT(value: v, next: head)
        if tail == nil {
            tail = head
        }
    }

    func pop() -> Value? {
        guard let first = head else { return nil }
        head = first.next
        if head == nil {
            tail = nil
        }
        return first.value
    }

    func append(_ v: Value) {
        let node = NodeT(value: v,
                         next: nil)
        if let tail = tail {
            tail.next = node
        } else {
            head = node
        }
        tail = node
    }

    func insert(_ list: LinkedList,
                after: NodeT? = nil)
    {
        if let after = after {
            assert(contains(where: { $0 === after }))

            list.last?.next = after.next
            after.next = list.first
        } else {
            list.last?.next = head
            head = list.first
        }
        if last == nil {
            tail = list.last
        }
    }

    func insert(_ values: [Value]) {
        values.reversed().forEach { value in
            push(value)
        }
    }

    func removeFirst(_ k: Int,
                     after: NodeT?) -> Self
    {
        guard k > 0 else { return Self(head: nil) }

        let result: NodeT?
        let lastTaken: NodeT?

        if let after = after {
            assert(contains(where: { $0 === after }))

            result = after.next
            lastTaken = result?.next(k - 1)
            after.next = lastTaken?.next
        } else {
            result = head
            lastTaken = result?.next(k - 1)
            head = lastTaken?.next
        }

        lastTaken?.next = nil

        if lastTaken == nil || tail === lastTaken {
            tail = head
        }

        return Self(head: result)
    }
}

public extension LinkedList {
    func circularRotate(to node: NodeT) -> Bool where Value: Comparable {
        guard !(head === node) else {
            // already rotated
            return true
        }
        guard let nodeBefore = findNodeBefore(node: node) else {
            // node isn't in the list
            return false
        }

        let shift = head
        nodeBefore.next = nil
        assert(shift?.last === nodeBefore)

        head = node
        node.last.next = shift

        tail = nodeBefore
        return true
    }
}
