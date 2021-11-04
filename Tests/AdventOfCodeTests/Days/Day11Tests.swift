//
//  File.swift
//
//
//  Created by Griff on 12/27/20.
//

import AdventOfCode
import ParserCombinator
import XCTest

final class Day11Tests: XCTestCase {
    let input = resourceURL(filename: "Day11Input.txt")!.readContents()!

    let example = """
    L.LL.LL.LL
    LLLLLLL.LL
    L.L.L..L..
    LLLL.LL.LL
    L.LL.LL.LL
    L.LLLLL.LL
    ..L.L.....
    LLLLLLLLLL
    L.LLLLLL.L
    L.LLLLL.LL
    """
}

extension Day11Tests {
    func testParseExample() {
        let lounge = Self.lounge.match(example)
        XCTAssertNotNil(lounge)
        XCTAssertEqual(lounge?.seatingChart.count, 10)
    }

    func testParseInput() {
        let lounge = Self.lounge.match(input)
        XCTAssertNotNil(lounge)
        XCTAssertEqual(lounge?.seatingChart.count, 98)
    }

    func testSeatUntilStableExample() {
        let lounge = Self.lounge.match(example)!

        let neighboringSeats = lounge.neighboringSeats()
        let stableSeating = lounge.seatUntilStable { index, wasOccupied in
            Lounge.willBeOccupied(index,
                                  wereOccupied: wasOccupied,
                                  croudedCount: 4,
                                  neighboringSeats)
        }
        XCTAssertEqual(stableSeating.iterations, 6)
        XCTAssertEqual(stableSeating.finalSeating.count, 37)
    }

    func testSeatUntilStableInput() {
        let lounge = Self.lounge.match(input)!

        let neighboringSeats = lounge.neighboringSeats()
        let stableSeating = lounge.seatUntilStable { index, wasOccupied in
            Lounge.willBeOccupied(index,
                                  wereOccupied: wasOccupied,
                                  croudedCount: 4,
                                  neighboringSeats)
        }
        XCTAssertEqual(stableSeating.iterations, 82)
        XCTAssertEqual(stableSeating.finalSeating.count, 2386)
    }

    func testSeatUntilStableLineOfSightExample() {
        let lounge = Self.lounge.match(example)!

        let neighboringSeats = lounge.neighboringSeatsLineOfSight()
        let stableSeating = lounge.seatUntilStable { index, wasOccupied in
            Lounge.willBeOccupied(index,
                                  wereOccupied: wasOccupied,
                                  croudedCount: 5,
                                  neighboringSeats)
        }
        XCTAssertEqual(stableSeating.iterations, 7)
        XCTAssertEqual(stableSeating.finalSeating.count, 26)
    }

    func testSeatUntilStableLineOfSightInput() {
        let lounge = Self.lounge.match(input)!

        let neighboringSeats = lounge.neighboringSeatsLineOfSight()
        let stableSeating = lounge.seatUntilStable { index, wasOccupied in
            Lounge.willBeOccupied(index,
                                  wereOccupied: wasOccupied,
                                  croudedCount: 5,
                                  neighboringSeats)
        }
        XCTAssertEqual(stableSeating.iterations, 88)
        XCTAssertEqual(stableSeating.finalSeating.count, 2091)
    }
}

extension Day11Tests {
    struct Lounge {
        let seatingChart: [[Character]]
        let indexRange: IndexingRange<Index2D>
        let chairIndicies: Set<Index2D>

        init(seatingChart: [[Character]]) {
            let indexRange = IndexingRange<Index2D>(
                min: .zero,
                max: .init(seatingChart.first!.count - 1, seatingChart.count - 1)
            )
            let chairIndicies = Index2D.indicesInRange(indexRange)
                .filter { i in seatingChart[i.y][i.x] == "L" }

            self.seatingChart = seatingChart
            self.indexRange = indexRange
            self.chairIndicies = Set(chairIndicies)
        }

        typealias NeighboringSeats = [Index2D: [Index2D]]
        func neighboringSeats() -> NeighboringSeats {
            chairIndicies
                .reduce(into: NeighboringSeats()) { result, chairIndex in
                    let neighbors = Index2D.neighborOffsets
                        .map { offset in
                            chairIndex + offset
                        }
                        .filter(chairIndicies.contains)

                    result[chairIndex] = neighbors
                }
        }

        func neighboringSeatsLineOfSight() -> NeighboringSeats {
            chairIndicies
                .reduce(into: NeighboringSeats()) { result, chairIndex in
                    let neighbors = Index2D.neighborOffsets
                        .compactMap { offset -> Index2D? in
                            var index = chairIndex
                            while true {
                                index = index + offset
                                guard indexRange.contains(index) else { return nil }
                                if chairIndicies.contains(index) {
                                    return index
                                }
                            }
                        }

                    result[chairIndex] = neighbors
                }
        }

        typealias WillBeOccupied = (_ index: Index2D, _ wereOccupied: Set<Index2D>) -> Bool

        func seatUntilStable(_ willBeOccupied: WillBeOccupied) -> (iterations: Int, finalSeating: Set<Index2D>)
        {
            var occupied = Set<Index2D>()
            var previous: Set<Index2D>
            var seatingCount = 0
            repeat {
                seatingCount += 1
                previous = occupied
                occupied = seating(occupied, willBeOccupied)
            } while previous != occupied

            return (seatingCount, occupied)
        }

        func seating(_ wereOccupied: Set<Index2D>,
                     _ willBeOccupied: WillBeOccupied) -> Set<Index2D>
        {
            var nextSeating = Set<Index2D>()

            chairIndicies.forEach { index in
                if willBeOccupied(index, wereOccupied) {
                    nextSeating.insert(index)
                }
            }

            return nextSeating
        }

        static func willBeOccupied(_ index: Index2D,
                                   wereOccupied: Set<Index2D>,
                                   croudedCount: Int,
                                   _ neighboringSeats: NeighboringSeats) -> Bool
        {
            let wasOccupied = wereOccupied.contains(index)
            let neighborCount = occupiedNeighbors(neighbors: neighboringSeats[index]!,
                                                  occupied: wereOccupied)

            switch (wasOccupied, neighborCount) {
            case (false, 0):
                return true
            case let (true, c) where c >= croudedCount:
                return false
            default:
                return wasOccupied
            }
        }

        static func occupiedNeighbors(neighbors: [Index2D],
                                      occupied: Set<Index2D>) -> Int
        {
            neighbors
                .filter(occupied.contains)
                .count
        }
    }
}

extension Day11Tests {
    typealias P = Parser

    static let lounge = P.character(in: "L.").oneOrMore()
        .oneOrMore(separatedBy: "\n")
        .ignoring(P.whitespacesAndNewlines.zeroOrMore())
        .map { seats in Lounge(seatingChart: seats) }
}
