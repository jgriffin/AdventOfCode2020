//
//  SeatFinder.swift
//
//
//  Created by Griff on 12/21/20.
//

import Foundation

typealias PlaneRange = ClosedRange<Int>

extension PlaneRange {
    var only: Bound? { count == 1 ? lowerBound : nil }

    enum BisectDirection { case lower, higher }
    var mid: (quotient: Int, remainder: Int) { (lowerBound + upperBound).quotientAndRemainder(dividingBy: 2) }

    func bisecting(_ d: BisectDirection) -> Self {
        .init(uncheckedBounds: { switch d {
        case .higher: return (mid.quotient + mid.remainder, upperBound)
        case .lower: return (lowerBound, mid.quotient)
        }}())
    }

    mutating func bisect(_ d: BisectDirection) { self = bisecting(d) }
}

struct SeatFinder {
    struct Seat: CustomStringConvertible {
        let row, seat: Int
        var seatId: Int { row * 8 + seat }

        var description: String { "row: \(row) seat: \(seat) seatId: \(seatId)" }
    }

    var seat: Seat? {
        guard let r = row.only,
              let c = col.only
        else {
            return nil
        }
        return Seat(row: r, seat: c)
    }

    var row: PlaneRange = 0 ... 127
    var col: PlaneRange = 0 ... 7

    enum Direction { case F, B, L, R }
    mutating func move(_ dir: Direction) {
        switch dir {
        case .F: row.bisect(.lower)
        case .B: row.bisect(.higher)
        case .L: col.bisect(.lower)
        case .R: col.bisect(.higher)
        }
    }

    static let chDirMap: [Character: Direction] = ["F": .F, "B": .B, "L": .L, "R": .R]
    mutating func move(_ ch: Character) { move(Self.chDirMap[ch]!) }

    static func seat(for ticket: String) -> Seat? {
        ticket.reduce(into: Self()) { $0.move($1) }.seat
    }
}
