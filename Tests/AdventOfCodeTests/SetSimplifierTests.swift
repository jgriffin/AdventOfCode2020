//
//  SetSimplifierTests.swift
//
//
//  Created by Griff on 12/25/20.
//

import AdventOfCode
import XCTest

final class SetSimplifierTests: XCTestCase {
    func testSingle() {
        let sets = [["test"].asSet]
        let result = SetSimplifier.uniqueify(sets)
        XCTAssertEqual(result, [Set(["test"])])
    }

    func testTwoSingles() {
        let sets = [["test"].asSet, ["zest"].asSet]
        let result = SetSimplifier.uniqueify(sets)
        XCTAssertEqual(result, [["test"].asSet, ["zest"].asSet])
    }

    func testTwo() {
        let sets = [["test"].asSet, ["test", "zest"].asSet]
        let result = SetSimplifier.uniqueify(sets)
        XCTAssertEqual(result, [["test"].asSet, ["zest"].asSet])
    }

    func testTwosAndAThree() {
        let sets = [["test", "zest"].asSet,
                    ["test", "zest"].asSet,
                    ["test", "zest", "nest"].asSet]
        let result = SetSimplifier.uniqueify(sets)
        XCTAssertEqual(result, [["test", "zest"].asSet,
                                ["test", "zest"].asSet,
                                ["nest"].asSet])
    }
}
