//
//  Day13Tests.swift
//
//
//  Created by Griff on 1/2/21.
//

import AdventOfCode
import EulerTools
import ParserCombinator
import XCTest

final class Day13Tests: XCTestCase {
    let input = resourceURL(filename: "Day13Input.txt")!.readContents()!

    let example = """
    939
    7,13,x,x,59,x,31,19
    """
}

extension Day13Tests {
    func testParseBusScheduleExample() {
        let schedule = Self.busSchedule.match(example)
        XCTAssertNotNil(schedule)
    }

    func testNextBusExample() {
        let schedule = Self.busSchedule.match(example)!
        let nextBusses = schedule.busses
            .compactMap { bus -> (id: Int, departure: Int)? in
                guard let id = bus.id,
                      let nextDeparture = bus.nextDepartureAfter(schedule.departure) else { return nil }
                return (id, nextDeparture)
            }

        let min = nextBusses.min(by: { lhs, rhs in lhs.departure < rhs.departure })!
        print("id: \(min.id) \(min.departure)")
        XCTAssertEqual(min.id, 59)
        XCTAssertEqual(min.departure, 944)
        let wait = min.departure - schedule.departure
        XCTAssertEqual(min.id * wait, 295)
    }

    func testNextBusInput() {
        let schedule = Self.busSchedule.match(input)!
        let nextBusses = schedule.busses
            .compactMap { bus -> (id: Int, departure: Int)? in
                guard let id = bus.id,
                      let nextDeparture = bus.nextDepartureAfter(schedule.departure) else { return nil }
                return (id, nextDeparture)
            }

        let min = nextBusses.min(by: { lhs, rhs in lhs.departure < rhs.departure })!
        print("id: \(min.id) \(min.departure)")
        XCTAssertEqual(min.id, 37)
        XCTAssertEqual(min.departure, 1_000_517)
        let wait = min.departure - schedule.departure
        XCTAssertEqual(min.id * wait, 296)
    }

    func testOffsetWaitsExample() {
        let busses = Self.busSchedule.match(example)!.busses
        let offsetAndBusIds = busses.enumerated()
            .compactMap { i, bus -> (i: Int, id: Int)? in
                guard let id = bus.id else { return nil }
                return (i, id)
            }

        let offsetDeparture = firstOffsetDeparture(offsetAndBusIds)
        XCTAssertEqual(offsetDeparture, 1_068_781)
    }

    func testOffsetWaitsCRTExample() {
        let busses = Self.busSchedule.match(example)!.busses
        let offsetAndBusIds = busses.enumerated()
            .compactMap { i, bus -> (i: Int, id: Int)? in
                guard let id = bus.id else { return nil }
                return (i, id)
            }

        let offsetDeparture = firstOffsetDepartureCRT(offsetAndBusIds)
        XCTAssertEqual(offsetDeparture, 1_068_781)
    }

    func testOffsetWaitsInput() {
        let busses = Self.busSchedule.match(input)!.busses
        let offsetAndBusIds = busses.enumerated()
            .compactMap { i, bus -> (i: Int, id: Int)? in
                guard let id = bus.id else { return nil }
                return (i, id)
            }
        print(offsetAndBusIds)

        let offsetDeparture = firstOffsetDepartureCRT(offsetAndBusIds)
        XCTAssertEqual(offsetDeparture, 535_296_695_251_210)
    }
}

extension Day13Tests {
    func firstOffsetDepartureCRT(_ offsetBusses: [(i: Int, id: Int)]) -> Int {
        let amis = offsetBusses
            .map { (ai: ($0.id - $0.i) % $0.id, mi: $0.id) }
        let timestamp = Int.chineseRemainderTheorem(amis)!
        return timestamp
    }

    func firstOffsetDeparture(_ offsetBusses: [(i: Int, id: Int)]) -> Int {
        let iAndBusIdReversed = offsetBusses
            .sorted { lhs, rhs in lhs.id < rhs.id }
            .reversed()
        let largestId = iAndBusIdReversed.first!

        var departure = largestId.id - largestId.i
        while !departureSatifiesAllOffsets(departure,
                                           offsetBusses)
        {
            departure += largestId.id
        }

        return departure
    }

    @inline(__always)
    func departureSatifiesAllOffsets(_ departure: Int,
                                     _ offsetBusses: [(i: Int, id: Int)]) -> Bool
    {
        offsetBusses
            .allSatisfy { i, id in (departure + i) % id == 0 }
    }
}

extension Day13Tests {
    struct Schedule {
        let departure: Int
        let busses: [Bus]
    }

    enum Bus: Equatable {
        case id(Int)
        case outOfService

        var id: Int? {
            switch self {
            case let .id(id): return id
            case .outOfService: return nil
            }
        }

        func nextDepartureAfter(_ time: Int) -> Int? {
            guard let id = id else { return nil }
            return ModuloUtils.numberAtLeast(time,
                                             whereModulo: id,
                                             equals: 0)
        }
    }
}

extension Day13Tests {
    typealias P = Parser

    static let departue = P.integer
    static let bus = oneOf(P.integer.map { no in Bus.id(no) },
                           P.character("x").map { _ in Bus.outOfService })
    static let busSchedule = zip(departue,
                                 P.newline,
                                 bus.oneOrMore(separatedBy: ","))
        .ignoring(P.whitespacesAndNewlines.zeroOrMore())
        .map { d, _, busses in Schedule(departure: d,
                                        busses: busses) }
}
