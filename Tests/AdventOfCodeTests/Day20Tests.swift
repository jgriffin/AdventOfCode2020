//
//  Day20Tests.swift
//
//
//  Created by Griff on 12/27/20.
//

import ParserCombinator
import XCTest

final class Day20Tests: XCTestCase {
    let input = resourceURL(filename: "Day20Input.txt")!.readContents()!
    let example = resourceURL(filename: "Day20Example.txt")!.readContents()!

    func testParseExample() {
        let tiles = Self.tiles.match(example)!
        XCTAssertEqual(tiles.count, 9)
    }

    func testFindCornersExample() {
        let tiles = Self.tiles.match(example)!
        let puzzle = Puzzle(tiles: tiles)
        let corners = puzzle.findCorners()
        XCTAssertEqual(corners.count, 4)

        let cornerIdProduct = corners.reduce(1, *)
        XCTAssertEqual(cornerIdProduct, 20_899_048_083_289)
    }

    func testFindCornersInput() {
        let tiles = Self.tiles.match(input)!
        let puzzle = Puzzle(tiles: tiles)
        let corners = puzzle.findCorners()
        XCTAssertEqual(corners.count, 4)

        let cornerIdProduct = corners.reduce(1, *)
        XCTAssertEqual(cornerIdProduct, 28_057_939_502_729)
    }
}

extension Day20Tests {
    struct Puzzle {
        let tiles: [Tile]

        typealias Edge2TileIds = [EdgeRef: [Tile.ID]]
        static func edge2TileMap(_ tiles: [Tile]) -> Edge2TileIds {
            tiles.reduce(into: Edge2TileIds()) { result, tile in
                tile.edgeRefs.forEach { edgeRef in
                    result[edgeRef, default: []].append(tile.id)
                }
            }
        }

        func findCorners() -> [Tile.ID] {
            let edgeRef2TileId = Self.edge2TileMap(tiles)
            let tileId2SharedEdgeCount = tiles
                .map { tile -> (id: Int, sharedCount: Int) in
                    let count = tile.edgeRefs
                        .filter { edgeRef2TileId[$0]!.count != 1 }
                        .count
                    return (tile.id, count)
                }

            let corners = tileId2SharedEdgeCount
                .filter { $0.sharedCount == 2 }

            return corners.map(\.id)
        }
    }
}

extension Day20Tests {
    struct Tile: Identifiable, CustomStringConvertible {
        let id: Int
        let rows: [[Character]]
        let edgeRefs: [EdgeRef]

        init(id: Int,
             rows: [[Character]])
        {
            self.id = id
            self.rows = rows
            edgeRefs = [
                rows.first!,
                rows.map { $0.last! },
                rows.last!.reversed(),
                rows.map { $0.first! },
            ].map(EdgeRef.init)
        }

        var description: String {
            "\(id):\n\(rows.map { String($0) }.interpolatedLines)"
        }
    }

    struct EdgeRef: Hashable {
        let signature: Int
        init(edge: [Character]) {
            signature = edge.hashValue ^ edge.reversed().hashValue
        }
    }
}

extension Day20Tests {
    typealias P = Parser

    static let tileNo = zip("Tile ", P.integer, ":")
        .map { _, id, _ in id }
    static let tileLine = P.character(in: ".#").oneOrMore()
    static let tileLines = tileLine.oneOrMore(separatedBy: "\n")
    static let tile = zip(tileNo, "\n", tileLines)
        .map { id, _, rows in Tile(id: id, rows: rows) }
    static let tiles = tile.oneOrMore(separatedBy: P.whitespacesAndNewlines)
        .ignoring(P.whitespaceAndNewline.zeroOrMore())
}
