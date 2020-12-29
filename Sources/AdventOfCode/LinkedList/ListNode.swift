//
//  ListNode.swift
//
//
//  Created by Griff on 12/28/20.
//

import Foundation

public class ListNode<Value> {
    public let value: Value
    public var next: ListNode<Value>?

    public init(value: Value,
                next: ListNode<Value>?)
    {
        self.value = value
        self.next = next
    }

    var last: ListNode<Value> {
        var prev = self
        while let next = prev.next {
            prev = next
        }
        return prev
    }

    func next(_ k: Int) -> ListNode<Value>? {
        if k == 0 {
            return self
        }
        return next?.next(k - 1)
    }
}

extension ListNode: Equatable where Value: Comparable {
    public static func == (lhs: ListNode<Value>, rhs: ListNode<Value>) -> Bool {
        lhs.value == rhs.value && lhs.next == rhs.next
    }
}

extension ListNode: Comparable where Value: Comparable {
    public static func < (lhs: ListNode<Value>, rhs: ListNode<Value>) -> Bool {
        lhs.value < rhs.value
    }
}
