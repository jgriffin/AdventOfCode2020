//
//  Day15Tests.swift
//
//
//  Created by Griff on 1/1/21.
//

import ParserCombinator
import XCTest

final class Day15Tests: XCTestCase {
    let input = "11,0,1,10,5,19"
    let example = "0,3,6"
}

extension Day15Tests {
    func testParseExample() {
        let numbers = Self.startingNumbers.match(example)
        XCTAssertEqual(numbers, [0, 3, 6])
    }

    func testTakeTurnExample() {
        let numbers = Self.startingNumbers.match(example)!

        var memory = Memory(startingNumbers: numbers)
        (1 ... 10).forEach { turn in
            let s = memory.takeTurn()
            print("turn \(turn): \(s)")
        }

        XCTAssertEqual(memory.lastSpoken, 0)
    }

    func testTakeTurn2024Example() {
        let numbers = Self.startingNumbers.match(example)!

        var memory = Memory(startingNumbers: numbers)
        (1 ... 2020).forEach { turn in
            let s = memory.takeTurn()
            print("turn \(turn): \(s)")
        }

        let last = memory.lastSpoken
        XCTAssertEqual(last, 436)
    }

    func testTakeTurn2024Input() {
        let numbers = Self.startingNumbers.match(input)!

        var memory = Memory(startingNumbers: numbers)
        (1 ... 2020).forEach { turn in
            let s = memory.takeTurn()
            print("turn \(turn): \(s)")
        }

        let last = memory.lastSpoken
        XCTAssertEqual(last, 870)
    }

    func testTakeTurn30000000Input() {
        let numbers = Self.startingNumbers.match(input)!

        var memory = Memory(startingNumbers: numbers)
        (1 ... 30_000_000).forEach { _ in
            _ = memory.takeTurn()
        }

        let last = memory.lastSpoken
        XCTAssertEqual(last, 9136)
    }
}

extension Day15Tests {
    struct Memory {
        var startingNumbers: [Int]
        var turn: Int = 0
        var previouslySpokenTurn: [Int: Int] = [:]
        var lastSpoken: Int?

        var debugSpoken: [Int] = []

        mutating func speak(_ n: Int) -> Int {
//            debugSpoken.append(n)
            lastSpoken = n
            return n
        }

        mutating func takeTurn() -> Int {
            let lastSpokenPreviously = lastSpoken.flatMap { previouslySpokenTurn[$0] }

            if let lastSpoken = lastSpoken {
                previouslySpokenTurn[lastSpoken] = turn
            }

            turn += 1

            guard turn > startingNumbers.count else {
                return speak(startingNumbers[turn - 1])
            }

            guard let previous = lastSpokenPreviously else {
                return speak(0)
            }

            let difference = turn - 1 - previous
            return speak(difference)
        }
    }
}

extension Day15Tests {
    typealias P = Parser
    static let startingNumbers = P.integer.zeroOrMore(separatedBy: ",")
}
