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
}

public extension Collection where Element: Hashable {
    var asSet: Set<Element> { Set(self) }
}
