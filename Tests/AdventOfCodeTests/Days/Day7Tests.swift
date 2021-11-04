//
//  Day7Tests.swift
//
//
//  Created by Griff on 12/21/20.
//

@testable import AdventOfCode
import ParserCombinator
import XCTest

// https://adventofcode.com/2020/day/7

final class Day7Tests: XCTestCase {
    let input = resourceURL(filename: "Day7Input.txt")!.readContents()!

    let example = """
    light red bags contain 1 bright white bag, 2 muted yellow bags.
    dark orange bags contain 3 bright white bags, 4 muted yellow bags.
    bright white bags contain 1 shiny gold bag.
    muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
    shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
    dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    faded blue bags contain no other bags.
    dotted black bags contain no other bags.
    """

    func testParseExampleByLine() {
        example.splitLines()
            .map(String.init).forEach { line in
                let constraint = ColoredBags.constraint.match(line)
                XCTAssertNotNil(constraint, line)
            }
    }

    func testParseInputByLine() {
        let lines = input.splitLines().map(String.init)
        XCTAssertEqual(lines.count, 594)

        lines.forEach { line in
            let constraint = ColoredBags.constraint.match(line)
            XCTAssertNotNil(constraint, line)
        }
    }

    func testParseExample() {
        let constraints = ColoredBags.constraints
            .match(example, completely: true)
        XCTAssertNotNil(constraints)
    }

    func testParseInput() {
        let constraints = zip(ColoredBags.constraints,
                              Parser.whitespaceAndNewline.zeroOrMore()).map(\.0)
            .match(input, completely: true)!
        XCTAssertEqual(constraints.count, 594)
        print(constraints.last.interpolated)
    }

    func testCanContainsExample() {
        let constraints = ColoredBags.constraints.match(example)!
        let backChecker = ColoredBags.BagChecker(constraints: constraints)

        let shinyGold = ColoredBags.Bag(pattern: "shiny", color: "gold")
        let canContain = backChecker.canContainsFor(shinyGold)
        XCTAssertEqual(canContain.count, 4)
    }

    func testCanContains2Input() {
        let constraints = zip(ColoredBags.constraints,
                              Parser.whitespaceAndNewline.zeroOrMore()).map(\.0).match(input)!
        let backChecker = ColoredBags.BagChecker(constraints: constraints)

        let shinyGold = ColoredBags.Bag(pattern: "shiny", color: "gold")

        let canContain = backChecker.canContainsFor(shinyGold)
        XCTAssertEqual(canContain.count, 208)
    }

    func testMustContainExample() {
        let constraints = ColoredBags.constraints.match(example)!
        let backChecker = ColoredBags.BagChecker(constraints: constraints)

        let shinyGold = ColoredBags.Bag(pattern: "shiny", color: "gold")
        let mustContain = backChecker.mustContain(shinyGold)
        XCTAssertEqual(mustContain, 32)
    }

    func testMustContainInput() {
        let constraints = zip(ColoredBags.constraints,
                              Parser.whitespaceAndNewline.zeroOrMore()).map(\.0).match(input)!
        let backChecker = ColoredBags.BagChecker(constraints: constraints)

        let shinyGold = ColoredBags.Bag(pattern: "shiny", color: "gold")
        let mustContain = backChecker.mustContain(shinyGold)
        XCTAssertEqual(mustContain, 1664)
    }
}
