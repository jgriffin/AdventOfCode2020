//
//  File.swift
//
//
//  Created by Griff on 12/21/20.
//

@testable import AdventOfCode
import Algorithms
import XCTest

final class Day5Tests: XCTestCase {
    let input = resourceURL(filename: "Day5Input.txt").flatMap(stringFromURL)!

    func testExamples() {
        let tests: [(ticket: String, check: (row: Int, seat: Int, seatId: Int))] = [
            ("FBFBBFFRLR", (44, 5, 357)),
            ("BFFFBBFRRR", (70, 7, 567)),
            ("FFFBBBFRRR", (14, 7, 119)),
            ("BBFFBBFRLL", (102, 4, 820)),
        ]

        tests.forEach { test in
            let seat = test.ticket.reduce(into: SeatFinder()) { $0.move($1) }.seat
            XCTAssertEqual(seat?.row, test.check.row)
            XCTAssertEqual(seat?.seat, test.check.seat)
            XCTAssertEqual(seat?.seatId, test.check.seatId)
        }
    }

    func testInputPart1() {
        let seats = input
            .split(separator: "\n")
            .map { SeatFinder.seat(for: String($0))! }

        let maxSeatId = seats
            .map(\.seatId)
            .max()

        XCTAssertEqual(maxSeatId, 980)
    }

    func testPart2() {
        let possibleSeats = product(0 ... 127, 0 ... 7)
            .map { SeatFinder.Seat(row: $0, seat: $1) }

        let occupiedSeats = input
            .split(separator: "\n")
            .map { SeatFinder.seat(for: String($0))! }

        let occupiedSeatIds = Set(occupiedSeats.map(\.seatId))

        let openSeats = possibleSeats.filter { !occupiedSeatIds.contains($0.seatId) }

        let openNearSeats = openSeats
            .filter { seat in
                occupiedSeatIds.contains(seat.seatId + 1) &&
                    occupiedSeatIds.contains(seat.seatId - 1)
            }

        print(openNearSeats.map(\.description).joined(separator: "\n"))
    }
}
