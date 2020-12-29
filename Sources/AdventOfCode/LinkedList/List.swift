//
//  Node.swift
//
//
//  Created by Griff on 12/28/20.
//

import Foundation

public protocol List: Sequence {
    associatedtype Value
    typealias NodeT = ListNode<Value>

    var isEmpty: Bool { get }
    var first: NodeT? { get }
    var last: NodeT? { get }

    func findNode(where: (Value) -> Bool) -> NodeT?

    func push(_ value: Value)
    func pop() -> Value?
    func append(_ value: Value)

    func insert(_ list: Self, after: NodeT?)
    func insert(_ values: [Value])

    func removeFirst(_ k: Int, after: NodeT?) -> Self
}

public extension List {
    func removeFirst(_ k: Int) -> Self {
        removeFirst(k, after: nil)
    }
}
