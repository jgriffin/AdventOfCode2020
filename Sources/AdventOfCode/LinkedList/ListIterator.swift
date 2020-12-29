//
//  ListIterator.swift
//
//
//  Created by Griff on 12/28/20.
//

import Foundation

public struct ListIterator<L: List>: IteratorProtocol {
    public let list: L
    public var current: L.NodeT?

    public init(list: L,
                current: L.NodeT? = nil)
    {
        self.list = list
        self.current = current ?? list.first
    }

    public mutating func next() -> L.NodeT? {
        defer { current = current?.next }
        return current
    }
}
