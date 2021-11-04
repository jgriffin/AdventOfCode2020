//
//  Day17Tests.swift
//
//
//  Created by Griff on 12/21/20.
//

import AdventOfCode
import ParserCombinator
import XCTest

final class Day17Tests: XCTestCase {
    let input = resourceURL(filename: "Day17Input.txt")!.readContents()!

    let example = """
    .#.
    ..#
    ###
    """
}

extension Day17Tests {
    func testParseExample() {
        let cubeSlice = Self.cubeSlice.match(example)!
        XCTAssertEqual(cubeSlice.count, 3)
    }

    func testParseInput() {
        let cubeSlice = Self.cubeSlice.match(input)!
        XCTAssertEqual(cubeSlice.first!.count, cubeSlice.count)
        XCTAssertEqual(cubeSlice.count, 8)
    }

    func testBoxOfInterest() {
        let cubeSlice = Self.cubeSlice.match(example)!

        var conway = Conway<Index3D>()
        conway.setFromCubeSlice(cubeSlice)

        let box = conway.boxOfInterest()!
        XCTAssertEqual(box.min, .init(-1, -1, -1))
        XCTAssertEqual(box.max, .init(3, 3, 1))

        let indices = Index3D.indicesInRange(box)
        XCTAssertEqual(indices.count, 5 * 5 * 3)
    }

    func testCyclesExample() {
        let cubeSlice = Self.cubeSlice.match(example)!
        var conway = Conway<Index3D>()
        conway.setFromCubeSlice(cubeSlice)

        let result = (1 ... 6).reduce(conway) { previous, _ in
            previous.nextCycle()
        }

        XCTAssertEqual(result.activeCubes.count, 112)
    }

    func testCyclesInput() {
        let cubeSlice = Self.cubeSlice.match(input)!
        var conway = Conway<Index3D>()
        conway.setFromCubeSlice(cubeSlice)

        let result = (1 ... 6).reduce(conway) { previous, _ in
            previous.nextCycle()
        }

        XCTAssertEqual(result.activeCubes.count, 207)
    }

    func testCycles4DExample() {
        let cubeSlice = Self.cubeSlice.match(example)!
        var conway = Conway<Index4D>()
        conway.setFromCubeSlice(cubeSlice)

        let result = (1 ... 6).reduce(conway) { previous, _ in
            previous.nextCycle()
        }

        XCTAssertEqual(result.activeCubes.count, 848)
    }

    func testCycles4DInput() {
        let cubeSlice = Self.cubeSlice.match(input)!
        var conway = Conway<Index4D>()
        conway.setFromCubeSlice(cubeSlice)

        let result = (1 ... 6).reduce(conway) { previous, _ in
            previous.nextCycle()
        }

        XCTAssertEqual(result.activeCubes.count, 2308)
    }
}

extension Day17Tests {
    struct Conway<Index: Indexing> {
        var activeCubes = Set<Index>()

        func isActive(_ index: Index) -> Bool {
            activeCubes.contains(index)
        }

        mutating func setActive(_ index: Index, active: Bool = true) {
            if active {
                activeCubes.insert(index)
            } else {
                activeCubes.remove(index)
            }
        }

        func nextCycle() -> Conway {
            var nextConway = Conway()
            let box = boxOfInterest()!

            Index.indicesInRange(box)
                .filter(willBeActive)
                .forEach { index in
                    nextConway.setActive(index)
                }

            return nextConway
        }

        func willBeActive(_ index: Index) -> Bool {
            switch (isActive(index), neighborCubeCount(index)) {
            case (true, 2), (true, 3):
                return true
            case (true, _):
                return false
            case (false, 3):
                return true
            case (false, _):
                return false
            }
        }

        func neighborCubeCount(_ index: Index) -> Int {
            Index.neighborOffsets
                .map { index + $0 }
                .filter { isActive($0) }
                .count
        }

        func boxOfInterest() -> IndexingRange<Index>? {
            guard let first = activeCubes.first else { return nil }

            // one extra on all sides
            let minIndex = activeCubes.reduce(first, Index.min) + Index.unitMinus
            let maxIndex = activeCubes.reduce(first, Index.max) + Index.unitPlus
            return .init(min: minIndex, max: maxIndex)
        }

        mutating func setFromCubeSlice(_ cubeSlice: [[Character]]) where Index == Index3D {
            for x in 0 ..< cubeSlice.first!.count {
                for y in 0 ..< cubeSlice.count {
                    if cubeSlice[y][x] == "#" {
                        setActive(.init(x, y, 0))
                    }
                }
            }
        }

        mutating func setFromCubeSlice(_ cubeSlice: [[Character]]) where Index == Index4D {
            for x in 0 ..< cubeSlice.first!.count {
                for y in 0 ..< cubeSlice.count {
                    if cubeSlice[y][x] == "#" {
                        setActive(.init(x, y, 0, 0))
                    }
                }
            }
        }
    }
}

extension Day17Tests {
    typealias P = Parser

    static let cubeSlice = P.character(in: ".#").oneOrMore()
        .zeroOrMore(separatedBy: "\n")
        .ignoring(P.whitespacesAndNewlines.zeroOrMore())
}
