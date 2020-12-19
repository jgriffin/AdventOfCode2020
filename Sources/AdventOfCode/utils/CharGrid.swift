//
//  CharGrid.swift
//
//
//  Created by Griff on 12/19/20.
//

import Foundation

public struct CharGrid {
    public let rows, cols: Int
    public var grid: [[Character]]
}

public extension CharGrid {
    init(substrings: [Substring]) {
        grid = substrings.map(Array.init)
        rows = grid.count
        cols = grid.first!.count
    }

    init(string: String) {
        self.init(substrings: string.splitLines())
    }

    subscript(x: Int, y: Int) -> Character {
        grid[y][x]
    }

    subscript(loc: IntLoc) -> Character {
        self[loc.x, loc.y]
    }
}
