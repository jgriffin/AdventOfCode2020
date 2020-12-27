//
//  Day14Tests.swift
//
//
//  Created by Griff on 12/26/20.
//

import Algorithms
import ParserCombinator
import XCTest

final class Day14Tests: XCTestCase {
    let input = resourceURL(filename: "Day14Input.txt")!.readContents()!

    let example = """
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
    """

    let example2 = """
    mask = 000000000000000000000000000000X1001X
    mem[42] = 100
    mask = 00000000000000000000000000000000X0XX
    mem[26] = 1
    """
}

extension Day14Tests {
    func testParseComponents() {
        let mask = Self.mask.run("mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X")
        XCTAssertEqual(mask.rest, "")
        XCTAssertEqual(mask.match, .mask(.fromChars("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X".asArray)))

        let assignment = Self.assignment.run("mem[8] = 11")
        XCTAssertEqual(assignment.rest, "")
        XCTAssertEqual(assignment.match, .assign(loc: 8, value: 11))
    }

    func testParseExample() {
        let instructions = Self.instructions.match(example)!
        XCTAssertEqual(instructions.count, 4)
    }

    func testParseInput() {
        let instructions = Self.instructions.match(input)!
        XCTAssertEqual(instructions.count, 561)
        XCTAssertEqual(instructions.last, .assign(loc: 20104, value: 662))
    }

    func testRunExample() {
        let instructions = Self.instructions.match(example)!
        var program = Program(instructions: instructions)
        program.run()
        let sumMems = program.mem.values.reduce(0, +)
        XCTAssertEqual(sumMems, 165)
    }

    func testRunInputs() {
        let instructions = Self.instructions.match(input)!
        var program = Program(instructions: instructions)
        program.run()
        let sumMems = program.mem.values.reduce(0, +)
        XCTAssertEqual(sumMems, 15_919_415_426_101)
    }

    func testRun2Example2() {
        let instructions = Self.instructions.match(example2)!
        var program = Program(instructions: instructions)
        program.run2()
        let sumMems = program.mem.values.reduce(0, +)
        XCTAssertEqual(sumMems, 208)
    }

    func testRun2Input() {
        let instructions = Self.instructions.match(input)!
        var program = Program(instructions: instructions)
        program.run2()
        let sumMems = program.mem.values.reduce(0, +)
        XCTAssertEqual(sumMems, 3_443_997_590_975)
    }
}

extension Day14Tests {
    struct Program {
        let instructions: [Instruction]

        var currentMask = BitsMask(mask: 0, bits: 0)
        var mem = [Int: Int]()

        mutating func run() {
            instructions.forEach { instruction in
                switch instruction {
                case let .mask(mask):
                    currentMask = mask

                case let .assign(loc: loc, value: value):
                    let maskedValue = (value & currentMask.mask) | currentMask.bits
                    mem[loc] = maskedValue
                }
            }
        }

        mutating func run2() {
            instructions.forEach { instruction in
                switch instruction {
                case let .mask(mask):
                    currentMask = mask

                case let .assign(loc: loc, value: value):

                    // handle floating
                    let floatingBits = (0 ..< 36).filter { i in (currentMask.mask & (1 << i)) != 0 }
                    let floatingCombinations = (0 ... floatingBits.count)
                        .flatMap { k in
                            floatingBits
                                .combinations(ofCount: k)
                                .map { $0.reduce(0) { result, next in result | (1 << next) } }
                        }

                    guard !floatingCombinations.isEmpty else {
                        // ones still become ones
                        mem[loc | currentMask.bits] = value
                        return
                    }

                    let fLocs = floatingCombinations
                        .map { locBits in
                            (loc & ~currentMask.mask) | locBits | currentMask.bits
                        }

                    fLocs.forEach { fLoc in
                        mem[fLoc] = value
                    }
                }
            }
        }
    }
}

extension Day14Tests {
    enum Instruction: Equatable {
        case mask(BitsMask)
        case assign(loc: Int, value: Int)
    }

    struct BitsMask: Equatable, CustomStringConvertible {
        let mask: Int
        let bits: Int

        func push(_ maskBit: Bool, _ bitBit: Bool) -> BitsMask {
            .init(mask: mask << 1 | (maskBit ? 1 : 0),
                  bits: bits << 1 | (bitBit ? 1 : 0))
        }

        static func fromChars(_ chars: [Character]) -> BitsMask {
            chars
                .reduce(BitsMask(mask: 0, bits: 0)) { result, ch -> BitsMask in
                    switch ch {
                    case "X": return result.push(true, false)
                    case "1": return result.push(false, true)
                    case "0": return result.push(false, false)
                    default: fatalError()
                    }
                }
        }

        var description: String {
            let (maskShift, bitsShift) = (mask, bits)
            let chars = (0 ..< 36)
                .map { _ -> Character in
                    switch (maskShift & 1, bitsShift & 1) {
                    case (1, 0): return "X"
                    case (1, 1): fatalError()
                    case (0, 1): return "1"
                    case (0, 0): return "0"
                    default: fatalError()
                    }
                }
                .reversed()

            return String(chars)
        }
    }
}

extension Day14Tests {
    typealias P = Parser

    static let mask = zip("mask = ", P.nextChar.takeCount(36))
        .map { _, m in Instruction.mask(.fromChars(m)) }

    static let assignment = zip("mem[", P.integer, "] = ", P.integer)
        .map { _, loc, _, value in Instruction.assign(loc: loc, value: value) }

    static let instructions = oneOf(mask, assignment)
        .oneOrMore(separatedBy: "\n")
        .ignoring(P.whitespaceAndNewline.zeroOrMore())
}
