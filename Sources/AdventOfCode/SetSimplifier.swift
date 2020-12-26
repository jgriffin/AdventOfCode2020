//
//  SetSimplifier.swift
//
//
//  Created by Griff on 12/25/20.
//

import Foundation

public struct SetSimplifier<Element: Hashable> {
    public typealias S = Set<Element>

    public static func uniqueify(_ sets: [S]) -> [S] {
        var better = sets

        var before: [S]
        repeat {
            before = better
            better = uniquifySingles(better)
            if better != before { continue }

        } while better != before

        return better
    }

    static func uniquifySingles(_ sets: [S]) -> [S] {
        let singles = sets.enumerated()
            .filter { _, s in s.count == 1 }

        var better = sets
        singles.forEach { _, value in
            better = better.map { s in
                guard s.count > 1 else { return s }
                return s.subtracting(value)
            }
        }

        return better
    }
}
