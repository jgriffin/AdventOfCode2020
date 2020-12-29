//
//  File.swift
//
//
//  Created by Griff on 12/28/20.
//

import AdventOfCode
import ParserCombinator
import XCTest

final class Day23Test: XCTestCase {
    let input = "562893147"
    let example = "389125467"

    func testParseExample() {
        let cups = Self.cupsParser.match(example)!
        XCTAssertEqual(cups.count, 9)
        XCTAssertEqual(cups.last, 7)
    }

    func testMoveExample() {
        let cups = Self.cupsParser.match(example)!
        var crab = CrabWalk(cups: .init(values: cups))
        crab.move()

        XCTAssertEqual(crab.cups.map(\.value), [2, 8, 9, 1, 5, 4, 6, 7, 3])
    }

    func test10MovesExample() {
        let cups = Self.cupsParser.match(example)!
        var crab = CrabWalk(cups: .init(values: cups))
        (0 ..< 10).forEach { _ in
            crab.move()
        }

        XCTAssertEqual(crab.cups.map(\.value), [8, 3, 7, 4, 1, 9, 2, 6, 5])

        _ = crab.cups.circularRotate(to: crab.cups.findNode(where: { $0 == 1 })!)
        XCTAssertEqual(crab.cups.map(\.value), [1, 9, 2, 6, 5, 8, 3, 7, 4])
    }

    func test100MovesExample() {
        let cups = Self.cupsParser.match(example)!
        var crab = CrabWalk(cups: .init(values: cups))
        (0 ..< 100).forEach { _ in
            crab.move()
        }

        _ = crab.cups.circularRotate(to: crab.cups.findNode(where: { $0 == 1 })!)
        XCTAssertEqual(crab.cups.map(\.value), [1, 6, 7, 3, 8, 4, 5, 2, 9])
    }

    func test100MovesInput() {
        let cups = Self.cupsParser.match(input)!
        var crab = CrabWalk(cups: .init(values: cups))
        (0 ..< 100).forEach { _ in
            crab.move()
        }

        _ = crab.cups.circularRotate(to: crab.cups.findNode(where: { $0 == 1 })!)
        XCTAssertEqual(crab.cups.asArray, [1, 3, 8, 9, 2, 5, 7, 6, 4])

        let result = crab.cups.asArray.dropFirst()
            .reduce(0) { result, next in result * 10 + next }
        XCTAssertEqual(result, 38_925_764)
    }
}

extension Day23Test {
    typealias Cup = Int

    struct CrabWalk {
        var cups: LinkedList<Cup>

        mutating func move() {
            guard let current = cups.first else {
                fatalError()
            }
            let three = cups.removeFirst(3, after: current)
            let destination = pickDesination(from: current.value)
            cups.insert(three, after: destination)
            guard cups.circularRotate(to: current.next!) else { fatalError() }
        }

        func pickDesination(from cup: Cup) -> LinkedList<Cup>.NodeT? {
            if let maxLessThanCup = cups.filter({ $0.value < cup }).max() {
                return maxLessThanCup
            }

            guard let maxValue = cups.max() else {
                fatalError()
            }
            return maxValue
        }
    }
}

extension Day23Test {
    typealias P = Parser
    static let cupsParser = P.digit.map { Int(String($0))! }
        .oneOrMore()
}
