//
//  Day8Tests.swift
//
//
//  Created by Griff on 12/21/20.
//

import ParserCombinator
import XCTest

final class Day8Tests: XCTestCase {
    let input = resourceURL(filename: "Day8Input.txt")!.readContents()!

    let example = """
    nop +0
    acc +1
    jmp +4
    acc +3
    jmp -3
    acc -99
    acc +1
    jmp -4
    acc +6
    """

    func testParseComponents() {
        XCTAssertTrue(Self.acc.matches("acc +3"))
        XCTAssertTrue(Self.jmp.matches("jmp -3"))
        XCTAssertTrue(Self.nop.matches("nop +0"))
    }

    func testParseExample() {
        XCTAssertTrue(Self.program.matches(example))
    }

    func testParseInput() {
        let program = Self.program.match(input)
        XCTAssertNotNil(program)
        XCTAssertEqual(program?.lines.count, 631)
    }

    func testRunExample() {
        let program = Self.program.match(example)!

        let result = program.runUntilLoop()
        XCTAssertEqual(result.looped, true)
        XCTAssertEqual(result.acc, 5)
    }

    func testRunInput() {
        let program = Self.program.match(input)!

        let result = program.runUntilLoop()
        XCTAssertEqual(result.looped, true)
        XCTAssertEqual(result.acc, 2034)
    }

    func testTryJmpFixExample() {
        let program = Self.program.match(example)!

        let result = program.tryJmpFix()
        XCTAssertEqual(result?.fixLine, 7)
        XCTAssertEqual(result?.acc, 8)
    }

    func testTryJmpFixInput() {
        let program = Self.program.match(input)!

        let result = program.tryJmpFix()
        XCTAssertEqual(result?.fixLine, 328)
        XCTAssertEqual(result?.acc, 672)
    }
}

extension Day8Tests {
    struct Program: CustomStringConvertible {
        var lines: [Operation]
        let jmpLineNos: [Int]

        init(lines: [Operation]) {
            self.lines = lines

            jmpLineNos = lines.enumerated()
                .compactMap { lineNo, line -> Int? in
                    guard case .jmp = line else { return nil }
                    return lineNo
                }
        }

        func runUntilLoop() -> (looped: Bool, acc: Int) {
            var linesExecuted = Set<Int>()

            var currentLine = 0
            var accumulator = 0

            while currentLine >= 0,
                  currentLine < lines.count,
                  !linesExecuted.contains(currentLine)
            {
                linesExecuted.insert(currentLine)

                let current = lines[currentLine]
                switch current {
                case let .acc(arg):
                    accumulator += arg
                    currentLine += 1
                case let .jmp(arg):
                    currentLine += arg
                case .nop:
                    currentLine += 1
                }
            }

            return (currentLine != lines.count, accumulator)
        }

        func tryJmpFix() -> (fixLine: Int, acc: Int)? {
            var tryProgram = self

            for tryLine in jmpLineNos {
                // swap in nop
                tryProgram.lines[tryLine] = .nop(0)
                defer { tryProgram.lines[tryLine] = lines[tryLine] }

                let tryResult = tryProgram.runUntilLoop()
                if !tryResult.looped {
                    return (tryLine, tryResult.acc)
                }
            }

            return nil
        }

        var description: String {
            lines.enumerated()
                .map { i, op in "\(i) \(op)" }
                .joined(separator: "\n")
        }
    }

    enum Operation: CustomStringConvertible {
        case acc(Int)
        case jmp(Int)
        case nop(Int)

        var description: String {
            switch self {
            case let .acc(arg): return "acc \(arg)"
            case let .jmp(arg): return "jmp \(arg)"
            case let .nop(arg): return "nop \(arg)"
            }
        }
    }

    typealias P = Parser

    static let signedInt = zip(oneOf(P.literal("+").map { _ in 1 },
                                     P.literal("-").map { _ in -1 }),
                               P.integer)
        .map { sign, number in sign * number }

    static let acc = zip("acc", " ", signedInt)
        .map { _, _, arg in Operation.acc(arg) }
    static let jmp = zip("jmp", " ", signedInt)
        .map { _, _, arg in Operation.jmp(arg) }
    static let nop = zip("nop", " ", signedInt)
        .map { _, _, arg in Operation.nop(arg) }

    static let operation = oneOf(acc, jmp, nop)
    static let operations = operation.oneOrMore(separatedBy: "\n")

    static let program = zip(operations, P.whitespaceAndNewline.zeroOrMore())
        .map { operations, _ in Program(lines: operations) }
}
