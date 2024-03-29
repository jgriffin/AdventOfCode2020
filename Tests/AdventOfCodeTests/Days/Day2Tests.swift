//
//  File.swift
//
//
//  Created by John on 12/13/20.
//

import AdventOfCode
import ParserCombinator
import XCTest

final class Day2Tests: XCTestCase {
    typealias P = Parser

    let input = resourceURL(filename: "Day2Input.txt")
        .flatMap(stringFromURL)

    static let lineParser = zip(
        P.integer,
        P.character("-"),
        P.integer,
        P.space,
        P.letter,
        P.literal(": "),
        P.letters
    )
    .map { min, _, max, _, ch, _, pwd in
        PWDLine(min: min, max: max, ch: ch, pwd: String(pwd))
    }

    static let linesParser = lineParser.zeroOrMore(separatedBy: P.newline)

    func testParseLine() {
        let tests: [(line: String, check: PWDLine)] = [
            ("1-4 m: mrfmmbjxr", .init(min: 1, max: 4, ch: "m", pwd: "mrfmmbjxr")),
            ("5-16 b: bbbbhbbbbpbxbbbcb", .init(min: 5, max: 16, ch: "b", pwd: "bbbbhbbbbpbxbbbcb")),
        ]

        tests.forEach { test in
            do {
                let result = Self.lineParser.run(test.line).match
                XCTAssertEqual(result, test.check, test.line)
            }
        }
    }

    func testReadLines() {
        let parsed = Self.linesParser.run(input!).match

        XCTAssertEqual(parsed?.count, 1000)
    }

    func testValidPasswords() {
        let parsed = Self.linesParser.run(input!).match

        let valid = parsed!.filter(\.isValid)
        XCTAssertEqual(valid.count, 607)
    }

    func testValid2Passwords() {
        let parsed = Self.linesParser.run(input!).match

        let valid = parsed!.filter(\.isValid2)
        XCTAssertEqual(valid.count, 321)
    }

    // MARK: internal

    struct PWDLine: Equatable, CustomStringConvertible {
        let min: Int
        let max: Int
        let ch: Character
        let pwd: String

        init(min: Int, max: Int, ch: Character, pwd: String) {
            self.min = min
            self.max = max
            self.ch = ch
            self.pwd = pwd
        }

        var description: String {
            "\(min) - \(max) \(ch) \(pwd)"
        }

        var isValid: Bool {
            let charCounts = pwd.reduce(into: [Character: Int]()) { result, ch in
                result[ch, default: 0] += 1
            }

            let cch = charCounts[ch] ?? 0
            return min <= cch && cch <= max
        }

        // Each policy actually describes two positions in the password,
        // where 1 means the first character, 2 means the second character, and so on.
        // (Be careful; Toboggan Corporate Policies have no concept of "index zero"!)
        // Exactly one of these positions must contain the given letter.
        // Other occurrences of the letter are irrelevant for the purposes of policy enforcement.
        var isValid2: Bool {
            let minIsCh = pwd[pwd.index(pwd.startIndex, offsetBy: min - 1)] == ch
            let maxIsCh = pwd[pwd.index(pwd.startIndex, offsetBy: max - 1)] == ch

            return (minIsCh || maxIsCh) && !(minIsCh && maxIsCh)
        }
    }
}
