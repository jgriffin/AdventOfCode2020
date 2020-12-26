//
//  Sequence+.swift
//
//
//  Created by John on 12/13/20.
//

import Foundation

public extension Collection {
    func only() -> Element? {
        guard count == 1 else {
            print("only count \(count) not 1")
            return nil
        }
        return first
    }

    var asArray: [Element] { Array(self) }

    func reduceFirst<Result>(
        _ firstMap: (Element) -> Result,
        _ nextPartialResult: (Result, Element) throws -> Result
    ) rethrows -> Result {
        guard let first = first else { fatalError() }
        return try dropFirst().reduce(firstMap(first), nextPartialResult)
    }

    func reduceFirst<Result>(
        _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result where Element == Result
    {
        guard let first = first else { fatalError() }
        return try dropFirst().reduce(first, nextPartialResult)
    }
}

public extension Collection where Element: Hashable {
    var asSet: Set<Element> { Set(self) }
}
