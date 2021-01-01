//
//  Day24Tests.swift
//
//
//  Created by Griff on 1/1/21.
//

import AdventOfCode
import ParserCombinator
import XCTest

final class Day24Tests: XCTestCase {
    let input = resourceURL(filename: "Day24Input.txt")!.readContents()!

    let example = """
    sesenwnenenewseeswwswswwnenewsewsw
    neeenesenwnwwswnenewnwwsewnenwseswesw
    seswneswswsenwwnwse
    nwnwneseeswswnenewneswwnewseswneseene
    swweswneswnenwsewnwneneseenw
    eesenwseswswnenwswnwnwsewwnwsene
    sewnenenenesenwsewnenwwwse
    wenwwweseeeweswwwnwwe
    wsweesenenewnwwnwsenewsenwwsesesenwne
    neeswseenwwswnwswswnw
    nenwswwsewswnenenewsenwsenwnesesenew
    enewnwewneswsewnwswenweswnenwsenwsw
    sweneswneswneneenwnewenewwneswswnese
    swwesenesewenwneswnwwneseswwne
    enesenwswwswneneswsenwnewswseenwsese
    wnwnesenesenenwwnenwsewesewsesesew
    nenewswnwewswnenesenwnesewesw
    eneswnwswnwsenenwnwnwwseeswneewsenese
    neswnwewnwnwseenwseesewsenwsweewe
    wseweeenwnesenwwwswnew
    """
}

extension Day24Tests {
    func testParseExample() {
        let tiles = Self.tileIndices.match(example)!
        XCTAssertEqual(tiles.count, 20)
    }

    func testnwwsweeReturns() {
        let tile = Self.tileIndex.match("nwwswee")!
        XCTAssertEqual(tile, .zero)
    }

    func testExample() {
        let tiles = Self.tileIndices.match(example)!
        let floor = tiles.reduce(into: TileFloor()) { floor, tile in floor.flip(tile) }
        XCTAssertEqual(floor.blackTiles.count, 10)
    }

    func testInput() {
        let tiles = Self.tileIndices.match(input)!
        let floor = tiles.reduce(into: TileFloor()) { floor, tile in floor.flip(tile) }
        XCTAssertEqual(floor.blackTiles.count, 400)
    }

    func testDailyProgressExample() {
        let tiles = Self.tileIndices.match(example)!
        let floor = tiles.reduce(into: TileFloor()) { floor, tile in floor.flip(tile) }

        let after100 = (1 ... 100).reduce([floor]) { result, _ in
            result + [result.last!.dayProgress()]
        }

        XCTAssertEqual(after100.last!.blackTiles.count, 2208)
    }

    func testDailyProgressInput() {
        let tiles = Self.tileIndices.match(input)!
        let floor = tiles.reduce(into: TileFloor()) { floor, tile in floor.flip(tile) }

        let after100 = (1 ... 100).reduce([floor]) { result, _ in
            result + [result.last!.dayProgress()]
        }

        XCTAssertEqual(after100.last!.blackTiles.count, 3768)
    }
}

extension Day24Tests {
    struct TileFloor {
        var blackTiles = Set<TileIndex>()

        mutating func flip(_ tile: TileIndex) {
            blackTiles.toggle(tile)
        }

        func dayProgress() -> TileFloor {
            var nextDayBlackTiles = Set<TileIndex>()
            let range = areaOfInterest()!

            TileIndex.indicesInRange(range)
                .forEach { tile in
                    if blackTiles.contains(tile) {
                        switch blackNeighbors(tile) {
                        case 0:
                            break // white
                        case let x where x > 2:
                            break // white
                        default:
                            nextDayBlackTiles.insert(tile)
                        }
                    } else {
                        switch blackNeighbors(tile) {
                        case 2:
                            nextDayBlackTiles.insert(tile)
                        default:
                            break // white
                        }
                    }
                }

            return TileFloor(blackTiles: nextDayBlackTiles)
        }

        func areaOfInterest() -> IndexingRange<TileIndex>? {
            guard !blackTiles.isEmpty else { return nil }
            return IndexingRange(min: blackTiles.reduceFirst(TileIndex.min) + .unitMinus,
                                 max: blackTiles.reduceFirst(TileIndex.max) + .unitPlus)
        }

        static let neighborOffsets = Dir.allCases.map(\.offset)

        func blackNeighbors(_ tile: TileIndex) -> Int {
            Self.neighborOffsets
                .map { tile + $0 }
                .filter(blackTiles.contains)
                .count
        }

        func whiteNeighbors(_ tile: TileIndex) -> Int {
            Dir.allCases.count - blackNeighbors(tile)
        }
    }
}

extension Day24Tests {
    func testIndex() {}

    typealias TileIndex = Index2D
    typealias Offset = Index2D

    enum Dir: String, CaseIterable, CustomStringConvertible {
        case e, se, sw, w, nw, ne

        //       0,-1   1,-1
        //   -1,0    0,0   1, 0
        //       -1,1   0,1
        var offset: Offset {
            switch self {
            case .e: return .init(1, 0)
            case .se: return .init(0, 1)
            case .sw: return .init(-1, 1)
            case .w: return .init(-1, 0)
            case .nw: return .init(0, -1)
            case .ne: return .init(1, -1)
            }
        }

        var description: String { rawValue }
    }
}

extension Day24Tests {
    typealias P = Parser

    static let direction = oneOf("se", "sw", "nw", "ne", "e", "w")
        .map { Dir(rawValue: $0)! }
    static let tileIndex = direction.oneOrMore()
        .map { dirs in dirs.reduce(TileIndex.zero) { result, dir in result + dir.offset } }
    static let tileIndices = tileIndex.oneOrMore(separatedBy: "\n")
        .ignoring(P.whitespacesAndNewlines.zeroOrMore())
}
