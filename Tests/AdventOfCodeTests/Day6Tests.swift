//
//  Day6Tests.swift
//
//
//  Created by Griff on 12/21/20.
//

import ParserCombinator
import XCTest

final class Day6Tests: XCTestCase {
    let input = resourceURL(filename: "Day6Input.txt")!.readContents()!

    let example = """
    abc

    a
    b
    c

    ab
    ac

    a
    a
    a
    a

    b
    """

    typealias P = Parser
    typealias Form = [Substring]
    typealias Group = [Form]

    static let form = P.letter.oneOrMore()
    static let group = form.oneOrMore(separatedBy: "\n")
    static let groups = group.oneOrMore(separatedBy: "\n")

    func testExample() {
        let groups = Self.groups.match(example)!
        XCTAssertEqual(groups.count, 5)

        let groupYesses = groups.map { forms in
            forms.reduce(into: Set<Character>()) { $0.formUnion($1) }
        }

        let sum = groupYesses.map(\.count).reduce(0,+)
        XCTAssertEqual(sum, 11)
    }

    func testInput() {
        let groups = Self.groups.match(input)!
        XCTAssertEqual(groups.count, 459)

        let groupYesses = groups.map { forms in
            forms.reduce(into: Set<Character>()) { $0.formUnion($1) }
        }

        let sum = groupYesses.map(\.count).reduce(0,+)
        XCTAssertEqual(sum, 6259)
    }

    func test2Example() {
        let groups = Self.groups.match(example)!
        XCTAssertEqual(groups.count, 5)

        let groupYesses = groups.map { forms -> Set<Character> in
            let allYessses = forms.reduce(Set<Character>()) { $0.union($1) }
            return forms.reduce(allYessses) { $0.intersection($1) }
        }

        let sum = groupYesses.map(\.count).reduce(0,+)
        XCTAssertEqual(sum, 6)
    }

    func test2Input() {
        let groups = Self.groups.match(input)!

        let groupYesses = groups.map { forms -> Set<Character> in
            let allYessses = forms.reduce(Set<Character>()) { $0.union($1) }
            return forms.reduce(allYessses) { $0.intersection($1) }
        }

        let sum = groupYesses.map(\.count).reduce(0,+)
        XCTAssertEqual(sum, 3178)
    }
}
