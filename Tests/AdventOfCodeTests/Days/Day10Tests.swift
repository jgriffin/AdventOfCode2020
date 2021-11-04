//
//  Day10Tests.swift
//
//
//  Created by Griff on 12/22/20.
//

import AdventOfCode
import Algorithms
import ParserCombinator
import XCTest

final class Day10Tests: XCTestCase {
    let input = resourceURL(filename: "Day10Input.txt")!.readContents()!

    let simpleExample = """
    16
    10
    15
    5
    1
    11
    7
    19
    6
    12
    4
    """

    let example = """
    28
    33
    18
    42
    31
    14
    46
    20
    48
    47
    24
    23
    49
    45
    19
    38
    39
    11
    1
    32
    25
    35
    8
    17
    7
    9
    4
    2
    34
    10
    3
    """

    func testArrangementsExample() {
        guard let chargers = Self.chargers.match(example)?.sorted().reversed().asArray else {
            fatalError()
        }

        let po = Self.pathsOutWith(chargers: chargers)
        XCTAssertEqual(po[0], 19208)
    }

    func testArrangementsInput() {
        guard let chargers = Self.chargers.match(input)?.sorted().reversed().asArray else {
            fatalError()
        }

        let po = Self.pathsOutWith(chargers: chargers)
        XCTAssertEqual(po[0], 48_358_655_787_008)
    }

    static func pathsOutWith(chargers: [Int]) -> [Int: Int] {
        let voltages = chargers.sorted().reversed() + [0]
        let deviceVoltage = voltages.first! + 3

        let pathsOut = voltages
            .reduce(into: [deviceVoltage: 1]) {
                (result: inout [Int: Int], charger: Int) in
                result[charger] =
                    (result[charger + 1] ?? 0) +
                    (result[charger + 2] ?? 0) +
                    (result[charger + 3] ?? 0)
            }
        return pathsOut
    }

    func testParseSimple() {
        let chargers = Self.chargers.match(simpleExample)
        XCTAssertEqual(chargers?.count, 11)
    }

    func testParseExample() {
        let chargers = Self.chargers.match(example)
        XCTAssertEqual(chargers?.count, 31)
    }

    func testParseInput() {
        let chargers = Self.chargers.match(input)
        XCTAssertEqual(chargers?.count, 103)
    }

    func testDistributionSimpleExample() {
        let chargers = Self.chargers.match(simpleExample)!
        let sorted = (chargers + [0, chargers.max()! + 3]).sorted()
        let deltas = zip(sorted, sorted.dropFirst()).map { $0.1 - $0.0 }
        let counts = Dictionary(grouping: deltas) { e in e }
            .map { k, v in (jolts: k, count: v.count) }
        print(counts)
    }

    func testDistributionExample() {
        let chargers = Self.chargers.match(example)!
        let sorted = (chargers + [0, chargers.max()! + 3]).sorted()
        let deltas = zip(sorted, sorted.dropFirst()).map { $0.1 - $0.0 }
        let counts = Dictionary(grouping: deltas) { e in e }
            .map { k, v in (jolts: k, count: v.count) }
            .sorted { lhs, rhs -> Bool in lhs.jolts < rhs.jolts }
        print(counts)
    }

    func testDistributionInput() {
        let chargers = Self.chargers.match(input)!
        let sorted = (chargers + [0, chargers.max()! + 3]).sorted()
        let deltas = zip(sorted, sorted.dropFirst()).map { $0.1 - $0.0 }
        let counts = Dictionary(grouping: deltas) { e in e }
            .map { k, v in (jolts: k, count: v.count) }
            .sorted { lhs, rhs -> Bool in lhs.jolts < rhs.jolts }
        XCTAssertEqual(counts.map(\.jolts), [1, 3])
        XCTAssertEqual(counts.map(\.count), [70, 34])
        XCTAssertEqual(counts.map(\.count).reduce(1,*), 2380)
    }
}

extension Day10Tests {
    typealias P = Parser

    static let chargers = P.integer.oneOrMore(separatedBy: .newline)
        .ignoring(P.whitespaceAndNewline.zeroOrMore())

    typealias Voltage = Int
    typealias Voltages = [Voltage]
    typealias VoltageSet = Set<Voltage>
    typealias VoltageRange = ClosedRange<Voltages.Index>

    static func lessThan(lhs: Voltages, rhs: Voltages) -> Bool {
        for (l, r) in zip(lhs, rhs) {
            if l != r {
                return l < r
            }
        }
        return lhs.count < rhs.count
    }
}

extension Day10Tests {
    func testValidArrangementsSimpleExample() {
        let chargers = Self.chargers.match(simpleExample)!
        let arranger = ChargerArranger(chargers)
        let arrangments = arranger.findArrangements()
        XCTAssertEqual(arrangments.count, 8)
    }

    func testValidArrangementsExample() {
        let chargers = Self.chargers.match(example)!
        let arranger = ChargerArranger(chargers)
        let arrangments = arranger.findArrangements()
        XCTAssertEqual(arrangments.count, 19208)
    }

    func testValidArrangementsInput() {
        let chargers = Self.chargers.match(input)!
        let arranger = ChargerArranger(chargers)
        let arrangments = arranger.findArrangements()
        XCTAssertEqual(arrangments.count, -1)
    }

    struct ChargerArranger {
        let voltages: Set<Voltage>
        init<C: Collection>(_ voltages: C) where C.Element == Voltage {
            self.voltages = voltages.asSet
        }

        func findArrangements() -> [Voltages] {
            let target = voltages.max()!
            voltages.sorted().reversed().forEach { v in
                // prime the memos
                _ = findArrangements2(.init(from: v, to: target, voltages: voltages))
            }

            let result = findArrangements2(.init(from: 0, to: target, voltages: voltages))
            return result.map(Voltages.init)
        }

        struct FindParams: Hashable {
            let from: Voltage
            let to: Voltage
            let voltages: Set<Voltage>
        }

        let findArrangements2 = memoize { (findArrangements, p: FindParams) -> [[Voltage]] in
            guard p.from != p.to else { return [[p.from]] }

            let nexts = [1, 2, 3]
                .map { p.from + $0 }
                .filter { p.voltages.contains($0) }

            guard !nexts.isEmpty else { return [] }

            return nexts
                .map { next in FindParams(from: next, to: p.to, voltages: p.voltages) }
                .flatMap(findArrangements)
                .map { [p.from] + $0 }
        }

        func findArrangements3(v: Voltage, to: Voltage, _ tracker: StateTracker) {
            guard v != to else {
                tracker.emit()
                return
            }

            let nexts = [1, 2, 3]
                .map { v + $0 }
                .filter { voltages.contains($0) }

            guard !nexts.isEmpty else { return }

            return nexts.forEach { next in
                tracker.push(next)
                defer { tracker.pop() }
                findArrangements3(v: next, to: to, tracker)
            }
        }

        class StateTracker {
            var stack = [Voltage]()
            var emitted = [Voltages]()

            func push(_ v: Voltage) { stack.append(v) }
            func pop() { stack.removeLast() }
            func emit() {
                let voltages = Voltages(stack)
                emitted.append(voltages)
                print(voltages)
            }
        }
    }

    class Arranger {
        let voltages: Voltages

        init<C: Collection>(_ voltages: C) where C.Element == Voltage {
            self.voltages = ([0] + voltages).asSet.sorted()
        }

        var cache = [Voltages.SubSequence: Set<VoltageSet>]()

        func arrangements() -> Set<VoltageSet> {
            arrangements(voltages[...])
        }

        func arrangements(_ s: Voltages.SubSequence) -> Set<VoltageSet> {
            if let c = cache[s] {
                return c
            }

            let result: Set<VoltageSet>
            defer { cache[s] = result }

            assert(s.count > 1)
            guard s.count > 2 else {
                guard let first = s.first,
                      let last = s.last,
                      last - first <= 3
                else {
                    result = Set()
                    return result
                }
                result = Set([VoltageSet([first, last])])
                return result
            }

            let middleIndex = (s.startIndex + s.endIndex) / 2
            let left = arrangements(s[...middleIndex])
            let right = arrangements(s[middleIndex...])

            result = product(left, right)
                .map { l, r in l.union(r) }
                .asSet

            return result
        }
    }
}
