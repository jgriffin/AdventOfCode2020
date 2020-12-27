//
//  Day17Tests.swift
//
//
//  Created by Griff on 12/21/20.
//

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
        XCTAssertEqual(box.min, .init(x: -1, y: -1, z: -1))
        XCTAssertEqual(box.max, .init(x: 3, y: 3, z: 1))

        let indices = Index3D.indicesBetween(box.min, box.max)
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

            Index.indicesBetween(box.min, box.max)
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

        func boxOfInterest() -> (min: Index, max: Index)? {
            guard let first = activeCubes.first else { return nil }

            // one extra on all sides
            let minIndex = activeCubes.reduce(first, Index.min) + Index.unitMinus
            let maxIndex = activeCubes.reduce(first, Index.max) + Index.unitPlus
            return (minIndex, maxIndex)
        }

        mutating func setFromCubeSlice(_ cubeSlice: [[Character]]) where Index == Index3D {
            for x in 0 ..< cubeSlice.first!.count {
                for y in 0 ..< cubeSlice.count {
                    if cubeSlice[y][x] == "#" {
                        setActive(.init(x: x, y: y, z: 0))
                    }
                }
            }
        }

        mutating func setFromCubeSlice(_ cubeSlice: [[Character]]) where Index == Index4D {
            for x in 0 ..< cubeSlice.first!.count {
                for y in 0 ..< cubeSlice.count {
                    if cubeSlice[y][x] == "#" {
                        setActive(.init(x: x, y: y, z: 0, zz: 0))
                    }
                }
            }
        }
    }
}

protocol Indexing: Hashable {
    static func indicesBetween(_: Self, _: Self) -> [Self]

    static var zero: Self { get }
    static var unitPlus: Self { get }
    static var unitMinus: Self { get }

    static var neighborOffsets: [Self] { get }

    static func + (_: Self, _: Self) -> Self
    static func min(_: Self, _: Self) -> Self
    static func max(_: Self, _: Self) -> Self
}

extension Indexing {}

struct Index3D: Indexing, CustomStringConvertible {
    var x, y, z: Int
    var description: String { "\(x),\(y),\(z)" }

    static let zero = Self(x: 0, y: 0, z: 0)
    static let unitPlus = Self(x: 1, y: 1, z: 1)
    static let unitMinus = Self(x: -1, y: -1, z: -1)

    static let neighborOffsets: [Self] = {
        indicesBetween(.unitMinus, .unitPlus)
            .filter { $0 != .zero }
    }()

    static func indicesBetween(_ i1: Self,
                               _ i2: Self) -> [Self]
    {
        (i1.z ... i2.z).flatMap { z in
            (i1.y ... i2.y).flatMap { y in
                (i1.x ... i2.x).map { x in
                    Self(x: x, y: y, z: z)
                }
            }
        }
    }

    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    static func min(_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: Swift.min(lhs.x, rhs.x), y: Swift.min(lhs.y, rhs.y), z: Swift.min(lhs.z, rhs.z))
    }

    static func max(_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: Swift.max(lhs.x, rhs.x), y: Swift.max(lhs.y, rhs.y), z: Swift.max(lhs.z, rhs.z))
    }
}

struct Index4D: Indexing, CustomStringConvertible {
    var x, y, z, zz: Int
    var description: String { "\(x),\(y),\(z),\(zz)" }

    static let zero = Self(x: 0, y: 0, z: 0, zz: 0)
    static let unitPlus = Self(x: 1, y: 1, z: 1, zz: 1)
    static let unitMinus = Self(x: -1, y: -1, z: -1, zz: -1)

    static let neighborOffsets: [Self] = {
        indicesBetween(.unitMinus, .unitPlus)
            .filter { $0 != .zero }
    }()

    static func indicesBetween(_ i1: Self,
                               _ i2: Self) -> [Self]
    {
        (i1.zz ... i2.zz).flatMap { zz in
            (i1.z ... i2.z).flatMap { z in
                (i1.y ... i2.y).flatMap { y in
                    (i1.x ... i2.x).map { x in
                        Self(x: x, y: y, z: z, zz: zz)
                    }
                }
            }
        }
    }

    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x,
              y: lhs.y + rhs.y,
              z: lhs.z + rhs.z,
              zz: lhs.zz + rhs.zz)
    }

    static func min(_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: Swift.min(lhs.x, rhs.x),
              y: Swift.min(lhs.y, rhs.y),
              z: Swift.min(lhs.z, rhs.z),
              zz: Swift.min(lhs.zz, rhs.zz))
    }

    static func max(_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: Swift.max(lhs.x, rhs.x),
              y: Swift.max(lhs.y, rhs.y),
              z: Swift.max(lhs.z, rhs.z),
              zz: Swift.max(lhs.zz, rhs.zz))
    }
}

extension Day17Tests {
    typealias P = Parser

    static let cubeSlice = P.character(in: ".#").oneOrMore()
        .zeroOrMore(separatedBy: "\n")
        .ignoring(P.whitespacesAndNewlines.zeroOrMore())
}
