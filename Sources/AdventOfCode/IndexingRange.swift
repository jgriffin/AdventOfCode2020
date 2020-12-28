//
//  Indexing.swift
//
//
//  Created by Griff on 12/27/20.
//

import Algorithms
import Foundation

public struct IndexingRange<Index: Indexing> {
    public let min: Index
    public let max: Index

    public init(min: Index, max: Index) {
        self.min = min
        self.max = max
    }

    public func contains(_ index: Index) -> Bool {
        zip(min.components, index.components).allSatisfy { $0 <= $1 } &&
            zip(index.components, max.components).allSatisfy { $0 <= $1 }
    }
}
