//
//  Day9Tests.swift
//
//
//  Created by Griff on 12/22/20.
//

import ParserCombinator
import XCTest

final class Day9Tests: XCTestCase {
    let input = resourceURL(filename: "Day9Input.txt")!.readContents()!

    let example = """
    35
    20
    15
    25
    47
    40
    62
    55
    65
    95
    102
    117
    150
    182
    127
    219
    299
    277
    309
    576
    """

    func testParseExample() {
        let numbers = Self.numbers.match(example)!
        XCTAssertEqual(numbers.count, 20)
        XCTAssertEqual(numbers.asSet.count, numbers.count)
    }

    func testParseInput() {
        let numbers = Self.numbers.match(input)!
        XCTAssertEqual(numbers.count, 1000)
    }

    func testPair2Sum() {
        let numbers = (1 ... 25).asSet

        XCTAssertEqual(numbers.hasPair2Sum(26), true)
        XCTAssertEqual(numbers.hasPair2Sum(49), true)
        XCTAssertEqual(numbers.hasPair2Sum(100), false)
        XCTAssertEqual(numbers.hasPair2Sum(50), false)
    }

    func testAddRemove() {
        var numbers = (1 ... 25).asSet
        numbers.add(26, remove: 1)
        XCTAssertEqual(numbers.contains(1), false)
        XCTAssertEqual(numbers.contains(26), true)
    }

    func testFindInvalidsExample() {
        let validator = Validator(numbers: Self.numbers.match(example)!,
                                  preambleLength: 5)
        let invalids = validator.findInvalids()
        XCTAssertEqual(invalids.first, 127)
    }

    func testFindInvalidsInput() {
        let validator = Validator(numbers: Self.numbers.match(input)!,
                                  preambleLength: 25)
        let invalids = validator.findInvalids()
        XCTAssertEqual(invalids.first, 70_639_851)
    }

    func testContiguousSumExample() {
        let validator = Validator(numbers: Self.numbers.match(example)!,
                                  preambleLength: 5)
        let sumRange = validator.findContiguousSum(127)
        let sumNums = sumRange.map { validator.numbers[$0] }!
        let lowHigh = (low: sumNums.min(), high: sumNums.max())
        XCTAssertEqual(lowHigh.low, 15)
        XCTAssertEqual(lowHigh.high, 47)
    }

    func testContiguousSumInput() {
        let validator = Validator(numbers: Self.numbers.match(input)!,
                                  preambleLength: 25)
        let sumRange = validator.findContiguousSum(70_639_851)
        let sumNums = sumRange.map { validator.numbers[$0] }!
        let low = sumNums.min()!
        let high = sumNums.max()!
        XCTAssertEqual(low, 3_474_524)
        XCTAssertEqual(high, 4_774_716)
        XCTAssertEqual(low + high, 8_249_240)
    }

    struct Validator {
        let numbers: [Int]
        let preambleLength: Int

        init(numbers: [Int], preambleLength: Int) {
            self.numbers = numbers
            self.preambleLength = preambleLength
        }

        func findInvalids() -> [Int] {
            var invalids = [Int]()

            var buffer = numbers.prefix(preambleLength).asSet
            for index in preambleLength ..< numbers.count {
                if !buffer.hasPair2Sum(numbers[index]) {
                    invalids.append(numbers[index])
                }

                buffer.add(numbers[index], remove: numbers[index - preambleLength])
            }

            return invalids
        }

        func findContiguousSum(_ sum: Int) -> Range<Int>? {
            var running = 0
            var l = 0
            var r = 0

            while running != sum, r < numbers.count {
                if running < sum {
                    running += numbers[r]
                    r += 1
                } else {
                    running -= numbers[l]
                    l += 1
                }
            }

            guard running == sum else {
                return nil
            }

            return l ..< r
        }
    }
}

extension Set where Element == Int {
    func hasPair2Sum(_ sum: Int) -> Bool {
        for a in self {
            let mustB = sum - a

            if mustB > 0,
               mustB != a,
               contains(mustB)
            {
                return true
            }
        }
        return false
    }

    mutating func add(_ a: Int, remove r: Int) {
        remove(r)
        insert(a)
    }
}

extension Day9Tests {
    typealias P = Parser

    static let numbers = P.integer.oneOrMore(separatedBy: "\n")
        .ignoring(P.whitespaceAndNewline.zeroOrMore())
}
