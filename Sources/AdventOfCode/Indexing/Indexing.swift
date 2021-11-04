//
//  Indexing.swift
//
//
//  Created by Griff on 12/27/20.
//

import Foundation

public protocol Indexing: Hashable {
    var components: [Int] { get }
    static var componentCount: Int { get }
    static func fromComponents(_ components: [Int]) -> Self

    static func indicesInRange(_: IndexingRange<Self>) -> [Self]

    static var zero: Self { get }
    static var unitPlus: Self { get }
    static var unitMinus: Self { get }
    static var neighborOffsets: [Self] { get }

    static func + (_: Self, _: Self) -> Self
    static func - (_: Self, _: Self) -> Self
    static func min(_: Self, _: Self) -> Self
    static func max(_: Self, _: Self) -> Self
}

public extension Indexing {
    var description: String {
        components.map(String.init).joined(separator: ",")
    }

    static func mapComponents(_ lhs: Self, _ rhs: Self,
                              _ mapping: (Int, Int) -> Int) -> Self
    {
        let mapped = zip(lhs.components, rhs.components)
            .map(mapping)
        return Self.fromComponents(mapped)
    }

    static func + (_ lhs: Self, _ rhs: Self) -> Self { mapComponents(lhs, rhs, +) }
    static func - (_ lhs: Self, _ rhs: Self) -> Self { mapComponents(lhs, rhs, -) }
    static func min(_ lhs: Self, _ rhs: Self) -> Self { mapComponents(lhs, rhs, Swift.min) }
    static func max(_ lhs: Self, _ rhs: Self) -> Self { mapComponents(lhs, rhs, Swift.max) }
    static func makeZero() -> Self { fromComponents(Array(repeating: 0, count: componentCount)) }
    static func makeUnitPlus() -> Self { fromComponents(Array(repeating: 1, count: componentCount)) }
    static func makeUnitMinus() -> Self { fromComponents(Array(repeating: -1, count: componentCount)) }
}

public extension Indexing {
    static func makeNeighborOffsets() -> [Self] {
        let zero = Self.makeZero()
        let unitPlus = Self.makeUnitPlus()
        let unitMinus = Self.makeUnitMinus()

        let range = IndexingRange(min: unitMinus, max: unitPlus)
        return indicesInRange(range)
            .filter { $0 != zero }
    }
}
