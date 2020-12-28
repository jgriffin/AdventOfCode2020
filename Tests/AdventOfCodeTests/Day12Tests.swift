//
//  Day12Tests.swift
//
//
//  Created by Griff on 12/27/20.
//

import AdventOfCode
import ParserCombinator
import XCTest

final class Day12Tests: XCTestCase {
    let input = resourceURL(filename: "Day12Input.txt")!.readContents()!

    let example = """
    F10
    N3
    F7
    R90
    F11
    """
}

extension Day12Tests {
    func testParseExample() {
        let instructions = Self.instructions.match(example)!
        XCTAssertEqual(instructions.count, 5)
    }

    func testParseInput() {
        let instructions = Self.instructions.match(input)!
        XCTAssertEqual(instructions.count, 750)
    }

    func testFollowInstructionsExample() {
        let instructions = Self.instructions.match(example)!
        var ship = Ship()
        ship.followInstructions(instructions)

        XCTAssertEqual(ship.location, .init(17, -8))
        XCTAssertEqual(ship.manhattanDistance, 25)
    }

    func testFollowInstructionsInput() {
        let instructions = Self.instructions.match(input)!
        var ship = Ship()
        ship.followInstructions(instructions)

        XCTAssertEqual(ship.location, .init(-550, 744))
        XCTAssertEqual(ship.manhattanDistance, 1294)
    }

    func testFollowInstructions2Example() {
        let instructions = Self.instructions.match(example)!
        var ship = Ship()
        ship.followInstructions2(instructions)

        XCTAssertEqual(ship.location, .init(214, -72))
        XCTAssertEqual(ship.manhattanDistance, 286)
    }

    func testFollowInstructions2Input() {
        let instructions = Self.instructions.match(input)!
        var ship = Ship()
        ship.followInstructions2(instructions)

        XCTAssertEqual(ship.location, .init(-17866, -2726))
        XCTAssertEqual(ship.manhattanDistance, 20592)
    }
}

extension Day12Tests {
    struct Ship {
        typealias Location = Index2D
        var location = Location(0, 0)
        var direction: Direction = .E
        var waypoint = Location(10, 1)

        var manhattanDistance: Int { abs(location.x) + abs(location.y) }

        mutating func followInstructions(_ instructions: [Instruction]) {
            instructions.forEach { instruction in
                followInstruction(instruction)
            }
        }

        mutating func followInstruction(_ instruction: Instruction) {
            switch instruction.action {
            case .N:
                move(.N, instruction.value)
            case .S:
                move(.S, instruction.value)
            case .E:
                move(.E, instruction.value)
            case .W:
                move(.W, instruction.value)
            case .L:
                direction = direction.rotated(-instruction.value)
            case .R:
                direction = direction.rotated(instruction.value)
            case .F:
                move(direction, instruction.value)
            }
        }

        mutating func followInstructions2(_ instructions: [Instruction]) {
            instructions.forEach { instruction in
                followInstruction2(instruction)
            }
        }

        mutating func followInstruction2(_ instruction: Instruction) {
            switch instruction.action {
            case .N:
                moveWaypoint(.N, instruction.value)
            case .S:
                moveWaypoint(.S, instruction.value)
            case .E:
                moveWaypoint(.E, instruction.value)
            case .W:
                moveWaypoint(.W, instruction.value)
            case .L:
                rotateWaypoint(-instruction.value)
            case .R:
                rotateWaypoint(instruction.value)
            case .F:
                moveTowardWaypoint(instruction.value)
            }
        }

        mutating func move(_ direction: Direction, _ value: Int) {
            switch direction {
            case .N:
                location.y += value
            case .E:
                location.x += value
            case .S:
                location.y -= value
            case .W:
                location.x -= value
            }
        }

        mutating func moveWaypoint(_ direction: Direction, _ value: Int) {
            switch direction {
            case .N:
                waypoint.y += value
            case .E:
                waypoint.x += value
            case .S:
                waypoint.y -= value
            case .W:
                waypoint.x -= value
            }
        }

        mutating func rotateWaypoint(_ degrees: Int) {
            assert(degrees.isMultiple(of: 90))

            let clockwiseTurns = (degrees + 360) / 90
            (0 ..< clockwiseTurns).forEach { _ in
                // rotate right 90
                waypoint = .init(waypoint.y,
                                 waypoint.x * -1)
            }
        }

        mutating func moveTowardWaypoint(_ value: Int) {
            let delta = Location(value * waypoint.x,
                                 value * waypoint.y)
            location = location + delta
        }
    }
}

extension Day12Tests {
    enum Action: String, Equatable, CustomStringConvertible {
        case N, S, E, W // by value
        case L, R // degrees
        case F // in current direction

        var description: String { rawValue }
    }

    enum Direction: CaseIterable {
        case N, E, S, W

        func rotated(_ degrees: Int) -> Direction {
            assert(degrees.isMultiple(of: 90))

            let clockwiseTurns = (degrees + 360) / 90
            let cur = Self.allCases.firstIndex(of: self)!
            return Self.allCases[(cur + clockwiseTurns) % Self.allCases.count]
        }
    }

    struct Instruction: CustomStringConvertible {
        let action: Action
        let value: Int

        var description: String { "\(action) \(value)" }
    }
}

extension Day12Tests {
    typealias P = Parser

    static let action = P.nextChar
        .map { Action(rawValue: String($0))! }

    static let instruction = zip(action, P.integer)
        .map { a, v in Instruction(action: a, value: v) }

    static let instructions = instruction.oneOrMore(separatedBy: "\n")
        .ignoring(P.whitespacesAndNewlines.zeroOrMore())
}
